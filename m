From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
 packets
Date: Fri, 17 Dec 2010 10:26:28 +0100
Message-ID: <1292577988.2906.1.camel@edumazet-laptop>
References: <1292428252.3427.342.camel@edumazet-laptop>
	 <20101216211744.GA2191@del.dom.local>
	 <1292535039.2655.13.camel@edumazet-laptop>
	 <20101216220838.GB2191@del.dom.local>
	 <1292538363.2655.20.camel@edumazet-laptop>
	 <20101216224237.GC2191@del.dom.local>
	 <1292542305.2655.25.camel@edumazet-laptop>
	 <20101217073015.GA6907@ff.dom.local>
	 <1292573297.2655.42.camel@edumazet-laptop>
	 <20101217083413.GB6907@ff.dom.local>  <20101217085937.GC6907@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39803 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab0LQJ0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 04:26:34 -0500
Received: by wwa36 with SMTP id 36so452267wwa.1
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 01:26:33 -0800 (PST)
In-Reply-To: <20101217085937.GC6907@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 d=C3=A9cembre 2010 =C3=A0 08:59 +0000, Jarek Poplawski a=
 =C3=A9crit :
> On Fri, Dec 17, 2010 at 08:34:13AM +0000, Jarek Poplawski wrote:
> > On Fri, Dec 17, 2010 at 09:08:17AM +0100, Eric Dumazet wrote:
> > > Care to suggest an alternative patch, because I am lost at this p=
oint ?
> >=20
> > Just what I wrote earlier: consider one additional cloning in
> > dev_queue_xmit_nit
>=20
> Actually, it's enough to get time once and change it for all current
> clones in the loop.=20
>=20
> Jarek P.

I think we can add this after latest Changli patch :

He does one skb_clone() before calling the sniffers.
We could set timestamp on this clone, instead of original skb.

Problem solved.



