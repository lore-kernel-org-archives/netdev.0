From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Wed, 18 Jan 2012 16:40:53 +0100
Message-ID: <1326901253.2316.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F15D417.4050005@fud.no> <1326831948.2606.2.camel@edumazet-laptop>
	 <00f1ef555b452980aae95eb3028072f8@localhost>
	 <1326895569.2316.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <9903c7bcb83314b495e7378dae23e703@localhost>
	 <1326898746.2316.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <184325098dff696295968e09accafa9d@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43296 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445Ab2ARPk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 10:40:56 -0500
Received: by werb13 with SMTP id b13so460001wer.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 07:40:55 -0800 (PST)
In-Reply-To: <184325098dff696295968e09accafa9d@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 16:14 +0100, Tore Anderson a =C3=A9c=
rit :

> No problem. Bottom line, I'd like a "min_pmtu" IPv6 sysctl or somethi=
ng
> similar that would allow me to configure it so that the kernel would=20
> accept an arbitrary low PMTU being received in an ICMPv6 PTB. That=20
> would prevent having to deal with the Fragmentation headers completel=
y.

I agree, but first lets fix the bugs ;)

Once the allfrag feature works again, we can try to avoid it.
