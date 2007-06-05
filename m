From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC RTNETLINK 04/09]: Link creation API
Date: Tue, 5 Jun 2007 16:16:18 -0700
Message-ID: <20070605161618.2328c6c4@freepuppy>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<20070605141256.15650.37514.sendpatchset@localhost.localdomain>
	<20070605150303.5249e0c0@freepuppy>
	<4665EEF7.3000306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60125 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759139AbXFEX3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 19:29:08 -0400
In-Reply-To: <4665EEF7.3000306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Jun 2007 01:17:11 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > On Tue,  5 Jun 2007 16:12:57 +0200 (MEST)
> > Patrick McHardy <kaber@trash.net> wrote:
> > 
> > 
> >>[RTNETLINK]: Link creation API
> >>
> >>Add rtnetlink API for creating, changing and deleting software devices.
> >>
> >>Signed-off-by: Patrick McHardy <kaber@trash.net>
> >>
> > 
> > If you want I'll extend existing bridge netlink to use these.
> 
> 
> Are you talking about brige-port information or bridge device
> configuration? So far the API is not suitable for anything that
> currently uses IFLA_PROTINFO because the sender is not the driver
> which created the device and doesn't use AF_UNSPEC. For bridge
> device configuration it would certainly be nice to have, but I'm
> not sure yet how to handle enslave operations. So far my favourite
> idea is to add enslave/release operations to rtnl_link_ops and call
> them when IFLA_MASTER is set (so the netlink message would look like
> this: ifindex: eth0 master: br0 nlmsg_type: RTM_NETLINK). But I
> haven't really thought this through yet.

Was thinking AF_BRIDGE (we have it already so use it), and both
add/remove bridge, and enslave/unslave device.


> I would also like to add support for handling "secondary device state"
> like bridge port state and others that currently use IFLA_PROTINFO
> (a lot of the code is very similar to the generic code), but all ideas
> so far turned out not to work very well.
> 
> I'm leaving for a short vacation until Sunday tommorrow, so replies
> may be delayed :)


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
