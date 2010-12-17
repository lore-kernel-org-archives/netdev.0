From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
 packets
Date: Fri, 17 Dec 2010 09:08:17 +0100
Message-ID: <1292573297.2655.42.camel@edumazet-laptop>
References: <1292428252.3427.342.camel@edumazet-laptop>
	 <20101216211744.GA2191@del.dom.local>
	 <1292535039.2655.13.camel@edumazet-laptop>
	 <20101216220838.GB2191@del.dom.local>
	 <1292538363.2655.20.camel@edumazet-laptop>
	 <20101216224237.GC2191@del.dom.local>
	 <1292542305.2655.25.camel@edumazet-laptop>
	 <20101217073015.GA6907@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44827 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750Ab0LQIIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 03:08:23 -0500
Received: by wyb28 with SMTP id 28so364738wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 00:08:22 -0800 (PST)
In-Reply-To: <20101217073015.GA6907@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 d=C3=A9cembre 2010 =C3=A0 07:30 +0000, Jarek Poplawski a=
 =C3=A9crit :

> It is wrong because it brings back the inconsistency with ping etc.
> described by Alex Sidorenko in the changelog of netem patch, but
> use normal (not netem) ingress scheduling (ping results shouldn't
> depend on sniffers).

Care to explain why only netem should take care of this delaying
problem ?
If a packet is delayed on other qdisc, dont we have the same problem ?

Right now, ping lies, giving different results if a sniffer is active o=
r
not.

Care to suggest an alternative patch, because I am lost at this point ?

Thanks


