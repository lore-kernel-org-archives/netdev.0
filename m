From: "Massimiliano D'Angelo" <massidangelo@gmail.com>
Subject: ipv6 multicast listener on linux box acting as multicast router
Date: Wed, 11 Apr 2012 17:24:39 +0200
Message-ID: <CAKS9aaTsDYpMXfh4y4wi-7D7A75eLvq4iYS-niDLw55P_d-24w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:44081 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760177Ab2DKPYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 11:24:40 -0400
Received: by dake40 with SMTP id e40so1341422dak.11
        for <netdev@vger.kernel.org>; Wed, 11 Apr 2012 08:24:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,
I would like to have your opinion on a comment in the ip6mr.c file
(kernel 2.6.29.4). The comment follows:

/*
* RFC1584 teaches, that DVMRP/PIM router must deliver packets locally
* not only before forwarding, but after forwarding on all output
* interfaces. It is clear, if mrouter runs a multicasting
* program, it should receive packets not depending to what interface
* program is joined.
* If we will not make it, the program will have to join on all
* interfaces. On the other hand, multihoming host (or router, but
* not mrouter) cannot join to more than one interface - it will
* result in receiving multiple packets.
*/

Does the part "if we will not make it..." mean that such behaviour is
not yet implemented in the kernel? Looking at the code, it seems to me
that it is not yet implemented, but I would like someone to confirm
it.

As an implication, if I have a IPv6 multicast listener on a Linux box
acting as multicast router, do I need to have my application listening
on all the interfaces if I want to receive the multicast messages no
matter what is the interface from which they are received?

Thanks in advance for your help!
Massimiliano
