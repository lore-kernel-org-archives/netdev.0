From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC RTNETLINK 04/09]: Link creation API
Date: Wed, 06 Jun 2007 13:42:25 +0200
Message-ID: <46669DA1.9010706@trash.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>	<20070605141256.15650.37514.sendpatchset@localhost.localdomain>	<20070605150303.5249e0c0@freepuppy>	<4665EEF7.3000306@trash.net> <20070605161618.2328c6c4@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51415 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758569AbXFFLmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 07:42:49 -0400
In-Reply-To: <20070605161618.2328c6c4@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 06 Jun 2007 01:17:11 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>>If you want I'll extend existing bridge netlink to use these.
>>
>>
>>Are you talking about brige-port information or bridge device
>>configuration? So far the API is not suitable for anything that
>>currently uses IFLA_PROTINFO because the sender is not the driver
>>which created the device and doesn't use AF_UNSPEC. For bridge
>>device configuration it would certainly be nice to have, but I'm
>>not sure yet how to handle enslave operations. So far my favourite
>>idea is to add enslave/release operations to rtnl_link_ops and call
>>them when IFLA_MASTER is set (so the netlink message would look like
>>this: ifindex: eth0 master: br0 nlmsg_type: RTM_NETLINK). But I
>>haven't really thought this through yet.
> 
> 
> Was thinking AF_BRIDGE (we have it already so use it), and both
> add/remove bridge, and enslave/unslave device.


I think we should use two seperate families for bridge devices
and bridge ports. I'll think about the enslave operation some
more and try to add it next week.
