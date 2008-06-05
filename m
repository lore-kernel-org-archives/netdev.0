From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: multicast with multiple devices
Date: Thu, 5 Jun 2008 20:25:38 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0806052024240.29055@fbirervta.pbzchgretzou.qr>
References: <OF839A1C25.E7A3F5EA-ON8825745F.005E9988-8825745F.005FB2EC@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:56708 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbYFESZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 14:25:40 -0400
In-Reply-To: <OF839A1C25.E7A3F5EA-ON8825745F.005E9988-8825745F.005FB2EC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2008-06-05 19:25, David Stevens wrote:
>netdev-owner@vger.kernel.org wrote on 06/05/2008 02:54:54 AM:
>
>> But what if you do not have an application to begin with?
>> Does not the kernel do autonomic forwarding of multicast
>> like it does for unicast?
>
>        I'm not sure I understand your question, but if I
>do, then "no." The kernel uses multicasting itself on
>particular interfaces (e.g., with IPv6 neighbor discovery).
>Multicast packets are not forwarded unless the system
>is configured as a multicast router. Being a unicast
>router does not cause forwarding of multicast packets,
>and multicast routers maintain a completely separate
>routing table from the unicast routing table. Multicast
>routers and unicast routers need not be the same set
>of machines.
>        Really, multicast routing has nothing to do with
>unicast routing, and relying on the unicast routing
>table for multicast interface selection is usually
>just a source of application failures.

All I wanted to know is whether, and if s how, kernel-only
multicasting can be done, without the help of a userspace program
with perhaps the exception of setting up mc routes with iproute2.
Like..
  ip mr add 224/4 dev eth0
  ip mr add 224/4 dev eth1
and perhaps sysctl -w net.xyz.mc_forward=1, and the packets
should be routed --- ideally.
