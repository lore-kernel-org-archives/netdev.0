From: Andrian Nord <nightnord@gmail.com>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on dummy
Date: Wed, 23 Feb 2011 20:13:23 +0300
Message-ID: <20110223170512.GA10277@nord.niifaq.ru>
References: <20110221150710.GA5651@nord.niifaq.ru>
 <4D6282DB.2080204@free.fr>
 <20110221153421.GA6602@nord.niifaq.ru>
 <4D628DC3.9000400@free.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dc+cDN39EJAMEtIO"
Cc: lxc-users@lists.sourceforge.net, Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33459 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754716Ab1BWRN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 12:13:57 -0500
Received: by wyg36 with SMTP id 36so1057343wyg.19
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 09:13:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D628DC3.9000400@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--dc+cDN39EJAMEtIO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 21, 2011 at 05:07:31PM +0100, Daniel Lezcano wrote:
> I Cc'ed the netdev mailing list and Patrick in case my analysis is wrong=
=20
> or incomplete.

I'm confirming, that this happens only when macvlan's are onto dummy net
device. In case of some physical interface under macvlan there is no lost
packages and no broken checksums.

--dc+cDN39EJAMEtIO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk1lQDMACgkQZAqeN5KgLbSMpACePG6xiqgWSYkugv77nVGjbufn
W8MAoJtSBfSA2C6EUS8PneEwgjjsteo3
=YLYs
-----END PGP SIGNATURE-----

--dc+cDN39EJAMEtIO--
