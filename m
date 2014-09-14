From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv3 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Sun, 14 Sep 2014 08:21:09 -0400
Message-ID: <54158835.8000508@oracle.com>
References: <54146A37.5010108@oracle.com> <20140913.162101.515634682549373073.davem@davemloft.net> <5414FA4D.6030504@oracle.com>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49971 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbaINMVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 08:21:11 -0400
In-Reply-To: <5414FA4D.6030504@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2014 10:15 PM, David L Stevens wrote:

> I wouldn't say I like it, either, but the problem is that without it, we
> are tied to the least common denominator. Anything that doesn't support
> v1.6 of the VIO protocol is stuck at the low MTU and low throughput, and

To put things in perspective, in practice its only legacy linux today 
that will do the v1.0, and administrators are likely to want to upgrade
to the later version, so encumbering the code with legacy version 
support may end up becoming hard-to-maintain code?

> I think of it as an Ethernet connected to a virtual switch, and the ICMP
> errors are for PMTUD are analogous to IGMP snooping. This is not an Ethernet
> device alone-- those don't negotiate per-destination link MTUs. But nothing forces
> anyone to mix MTUs; the ICMP errors simply allow it.

As I understand it, this method of sending ICMP from the driver will not
work for L2 (non-IP) packets, and it will not even work for IP packets 
that are coming to us, from, say, openvswitch, right? So in practice it
actually has limited usability?

--Sowmini
