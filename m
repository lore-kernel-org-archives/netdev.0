From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Thu, 19 Feb 2009 21:19:40 +0300
Message-ID: <200902192119.52519.arvidjaar@mail.ru>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <200902172001.41804.arvidjaar@mail.ru> <499DA1AB.7040903@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2433081.I759VuEVDi";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	"J.A. =?iso-8859-1?q?Magall=F3n?=" <jamagallon@ono.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6.mail.ru ([94.100.176.86]:10066 "EHLO mx6.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbZBSSUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 13:20:04 -0500
In-Reply-To: <499DA1AB.7040903@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2433081.I759VuEVDi
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 19 of February 2009 21:15:07 Randy Dunlap wrote:
> Andrey Borzenkov wrote:
> > Forward to bonding and netdev
> >
> > On 17 of February 2009 11:52:32 J.A. Magall=F3n wrote:
> >> Hi all...
> >>
> >> Don't know if this is specific for -rc5, I have jumped from 28.4
> >> to 29-rc5. In this latest kernel, I can not install 'bonding'
> >> module if 'ipv6' is disabled to load via modprobe.conf:
> >>
> >> install ipv6 /bin/true
> >>
> >> Trying bonding gives this dmesg:
> >>
> >> bonding: Unknown symbol ndisc_build_skb
> >> bonding: Unknown symbol in6_dev_finish_destroy
> >> bonding: Unknown symbol ndisc_send_skb
> >> bonding: Unknown symbol unregister_inet6addr_notifier
> >> bonding: Unknown symbol register_inet6addr_notifier
> >>
> >> Commenting the line in modprobe.conf makes things smooth again.
> >> We can not disable ipv6 anymore ?
> >
> > If IPv6 is disable in kernel config bonding loads. But I think it
> > is regression, it should be possible to disable IPv6 if not
> > required.
>
> Just for clarification, is this a run-time (module load-time) error
> but not a build error?

Yes, this is run-time error. If IPV6 is disabled during kernel build,=20
everything works; but the error was seen on distribution kernel which=20
includes IPV6.

--nextPart2433081.I759VuEVDi
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkmdosAACgkQR6LMutpd94wPQgCgpwjsXscUiktzp3DHTi4i/MOg
2EwAniS/xgbLTQ7lar1WGMno9LJIjOKE
=HQsZ
-----END PGP SIGNATURE-----

--nextPart2433081.I759VuEVDi--
