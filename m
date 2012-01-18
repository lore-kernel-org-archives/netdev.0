From: Tore Anderson <tore@fud.no>
Subject: Re: [RFC] ipv6: =?UTF-8?Q?dst=5Fallfrag=28=29=20not=20taken=20into=20acco?=
 =?UTF-8?Q?unt=20by=20TCP?=
Date: Wed, 18 Jan 2012 13:42:52 +0100
Message-ID: <00f1ef555b452980aae95eb3028072f8@localhost>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F15D417.4050005@fud.no> <1326831948.2606.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:51239 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753806Ab2ARMmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 07:42:54 -0500
In-Reply-To: <1326831948.2606.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet

> Could you please test following patch ?

Hi,

It seems to work fine, now all the outgoing packets that includes a
Fragmentation header all are "atomic" or "non-fragmented" fragments,
i.e., that they both have Offset=0 and More Fragments=0.

I'm uploaded a tcpdump showing the traffic with the patch here:

https://bugzilla.kernel.org/attachment.cgi?id=72106

Best regards,
-- 
Tore Anderson
