From: Andre Naujoks <nautsch@gmail.com>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Thu, 6 Oct 2011 16:14:04 +0200
Message-ID: <CAOCMmudzoJH4EC81Tw6BCYQJjaNyNwt65sKFiMOvc5HKsvgKvw@mail.gmail.com>
References: <4E8C78E8.3010605@hartkopp.net>
	<20111005155127.GB13794@pengutronix.de>
	<4E8C8175.2040202@hartkopp.net>
	<4E8D528D.8020607@hartkopp.net>
	<4E8D7065.8040905@grandegger.com>
	<20111006092456.GB1974@pengutronix.de>
	<4E8DB4C9.30109@hartkopp.net>
	<20111006140904.GD1974@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:57403 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758384Ab1JFOOG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 10:14:06 -0400
Received: by qadb15 with SMTP id b15so1976248qad.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 07:14:05 -0700 (PDT)
In-Reply-To: <20111006140904.GD1974@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

2011/10/6 Wolfram Sang <w.sang@pengutronix.de>
>
> > Ah, i did not get this from your code example
> >
> > =A0 =A0 =A0 if (can_dlc & 1)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 *payload =3D in_be16() & mask;
>
> Sorry, I thought it was obvious that I was using pseudo_code here :)
>
> > ... it would be nice if e.g. Wolfgang could send his patch after so=
me testing,
> > as i currently don't have access to my MPC5200 hardware here.
>
> What about Andre?

I am currently trying to test the first version Oliver sent. I am
currently having some problems
with my hardware and I don't know what it is yet.

I will give Wolfgangs suggestion a try after my problems are sorted out=
 here.

Regards
  Andre

>
> Regards,
>
> =A0 Wolfram
>
> --
> Pengutronix e.K. =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
| Wolfram Sang =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|
> Industrial Linux Solutions =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | http://w=
ww.pengutronix.de/ =A0|
>
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.10 (GNU/Linux)
>
> iEYEARECAAYFAk6NtoAACgkQD27XaX1/VRudMQCeMX3yMc+Au65BwKDocJNXtG/d
> RxgAoJnY/p0csrHa0o/7SpnQdtEhEOQn
> =3DSxlb
> -----END PGP SIGNATURE-----
>
