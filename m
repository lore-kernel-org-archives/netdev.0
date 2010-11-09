From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip_summed setting for TCP pure-ACK packets
Date: Tue, 09 Nov 2010 17:28:46 +0100
Message-ID: <1289320126.2774.17.camel@edumazet-laptop>
References: <1289234113.2222.20.camel@achroite.uk.solarflarecom.com>
	 <1289235366.15376.3.camel@edumazet-laptop>
	 <1289319889.2238.195.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59186 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab0KIQ2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 11:28:52 -0500
Received: by wwb39 with SMTP id 39so164829wwb.1
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 08:28:51 -0800 (PST)
In-Reply-To: <1289319889.2238.195.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 16:24 +0000, Ben Hutchings a =C3=A9cri=
t :
> On Mon, 2010-11-08 at 17:56 +0100, Eric Dumazet wrote:=20
> > Le lundi 08 novembre 2010 =C3=A0 16:35 +0000, Ben Hutchings a =C3=A9=
crit :
> > > As we discussed at LPC:
> > >=20
> > > Current controllers handled by the sfc driver have a per-queue (r=
ather
> > > than per-packet) option for checksum generation.  Currently pure-=
ACK
> > > packets sent by TCP have ip_summed =3D=3D CHECKSUM_NONE and we mu=
st send
> > > them on hardware queues with checksum generation disabled.  To su=
pport
> > > this, we allocate 2 hardware queues per core TX queue.
> > >=20
> > > To reduce the risk of reordering (and possibly the number of hard=
ware TX
> > > queues required), it would be helpful for TCP to set ip_summed =3D=
=3D
> > > CHECKSUM_PARTIAL on pure-ACK packets when the output device is kn=
own to
> > > support checksum generation.
> > >=20
> > > Ben.
> > >=20
> >=20
> > Hmm
> >=20
> > Do you mean commit 2e8e18ef52e7dd1af0a3bd1 is not enough ?
>=20
> It might well be... I must admit I hadn't thought to check whether th=
is
> issue had gone away.
>=20
> Yes, that does the trick.  Sorry for wasting people's time on this.
>=20

You're welcome ;)



