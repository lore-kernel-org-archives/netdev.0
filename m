From: Andrew Savchenko <bircoph@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Sun, 14 Oct 2012 03:11:19 +0400
Message-ID: <20121014031119.a60263d6.bircoph@gmail.com>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	<20121013163639.87abca00.bircoph@gmail.com>
	<1350135860.21172.14606.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sun__14_Oct_2012_03_11_19_+0400_uP7rHoA_3c7lZ_CO"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:51476 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245Ab2JMXLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 19:11:33 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so2748998lbo.19
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2012 16:11:32 -0700 (PDT)
In-Reply-To: <1350135860.21172.14606.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Sun__14_Oct_2012_03_11_19_+0400_uP7rHoA_3c7lZ_CO
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On Sat, 13 Oct 2012 15:44:20 +0200 Eric Dumazet wrote:
> On Sat, 2012-10-13 at 16:36 +0400, Andrew Savchenko wrote:
> > On Wed, 3 Oct 2012 23:25:48 +0400 Andrew Savchenko wrote:
> > > I encountered a very weird bug: after a while of uptime kernel stops =
to deliver
> > > DNS reply to applications. Tcpdump shows that correct reply is reciev=
ed, but=20
> > > strace shows inquiring application never recieves it and ends with ti=
meout,
> > > epoll_wait() always returns 0:
> > > a slice from: $ host kernel.org 8.8.8.8:
[...]
> > > In a few days I'll try 3.4.12 (I need to rebuild kernel anyway due to=
 unrelated
> > > issue) and will report if this bug will occur again. But please note =
it may
> > > take several weeks to check this.
> >=20
> > I got this problem again with 3.4.12 kernel. System lasted less than
> > a week and reboot was the only option...
>=20
> You should investigate and check where the incoming packet is lost
>=20
> Tools :
>=20
> netstat -s
>=20
> drop_monitor module and dropwatch command
>=20
> cat /proc/net/udp

Thank you for you reply; I updated my kernel to 3.4.14, enabled
CONFIG_NET_DROP_MONITOR, and installed dropwatch utility.

I will report back when the bug will struck again.
This may take a weak or two, however.

Best regards,
Andrew Savchenko

--Signature=_Sun__14_Oct_2012_03_11_19_+0400_uP7rHoA_3c7lZ_CO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlB59SEACgkQ2anJBBcsZw1ehwCfa7iK6QlFPYSSMCwsw+jcccPA
KuIAn3pUDTGA+YgFUqAql1fJbf/USwLV
=hXPN
-----END PGP SIGNATURE-----

--Signature=_Sun__14_Oct_2012_03_11_19_+0400_uP7rHoA_3c7lZ_CO--
