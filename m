From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2/5709: Strange interrupts spread
Date: Mon, 19 Jul 2010 21:47:55 +0200
Message-ID: <1279568875.2458.0.camel@edumazet-laptop>
References: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
	 <AANLkTikfEED5Hvt80G6EnMwPBByMuw4r1Xg2ITjuZ0eV@mail.gmail.com>
	 <1279565231.20559.14.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christophe Ngo Van Duc <cngovanduc@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61290 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966448Ab0GSTsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 15:48:02 -0400
Received: by wwb39 with SMTP id 39so542822wwb.1
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 12:48:01 -0700 (PDT)
In-Reply-To: <1279565231.20559.14.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 juillet 2010 =C3=A0 11:47 -0700, Michael Chan a =C3=A9crit =
:
> On Mon, 2010-07-19 at 08:55 -0700, Christophe Ngo Van Duc wrote:
> > So i've been able to do some test today:
> > If I put the 2 interface in a bridge with no IP adress, the interru=
pts
> > are on 1 CPU
> > If I put the 2 interface in a bridge with IP adress, the interrupts
> > are still on 1 CPU
> > If I put the 2 interface outside the bridge with IP address,
> > everything works fine the interrupts get spread on the CPU
> >=20
> > So the conclusion seems to be that when the bnx2 is put into
> > promiscuous mode by the bridge, the RSS hash stop to work even if
> > traffic is IP in nature.
>=20
> I did a quick test with bridging and saw no problem with RSS.  I did =
see
> this though:
>=20
> br0 received packet on queue 4, but number of RX queues is 1
>=20
> Looks like it is a warning message from RPS.
>=20

Christophe uses an old kernel, not RPS enabled ;)



