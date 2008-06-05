From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast with multiple devices
Date: Thu, 5 Jun 2008 10:25:18 -0700
Message-ID: <OF839A1C25.E7A3F5EA-ON8825745F.005E9988-8825745F.005FB2EC@us.ibm.com>
References: <alpine.LNX.1.10.0806051154300.29055@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:46681 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbYFERZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 13:25:24 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m55HPNVl007099
	for <netdev@vger.kernel.org>; Thu, 5 Jun 2008 13:25:23 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m55HPM6j075506
	for <netdev@vger.kernel.org>; Thu, 5 Jun 2008 11:25:22 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m55HPLl6001573
	for <netdev@vger.kernel.org>; Thu, 5 Jun 2008 11:25:22 -0600
In-Reply-To: <alpine.LNX.1.10.0806051154300.29055@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 06/05/2008 02:54:54 AM:

> But what if you do not have an application to begin with?
> Does not the kernel do autonomic forwarding of multicast
> like it does for unicast?

        I'm not sure I understand your question, but if I
do, then "no." The kernel uses multicasting itself on
particular interfaces (e.g., with IPv6 neighbor discovery).
Multicast packets are not forwarded unless the system
is configured as a multicast router. Being a unicast
router does not cause forwarding of multicast packets,
and multicast routers maintain a completely separate
routing table from the unicast routing table. Multicast
routers and unicast routers need not be the same set
of machines.
        Really, multicast routing has nothing to do with
unicast routing, and relying on the unicast routing
table for multicast interface selection is usually
just a source of application failures.

                                                +-DLS

