From: "Witold Baryluk" <baryluk@smp.if.uj.edu.pl>
Subject: Re: [PATCH net-2.6] net: add skb_dst_force() in
 sock_queue_err_skb()
Date: Wed, 18 May 2011 16:25:19 +0200
Message-ID: <20110518142519.GH3539@smp.if.uj.edu.pl>
References: <1305673846.6741.35.camel@edumazet-laptop>
 <20110518.022151.1670373958008022789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_smp.if.uj.edu.pl-27946-1305728721-0001-2"
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smp.if.uj.edu.pl ([149.156.82.206]:40236 "EHLO smp.if.uj.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757193Ab1EROa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2011 10:30:26 -0400
Content-Disposition: inline
In-Reply-To: <20110518.022151.1670373958008022789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_smp.if.uj.edu.pl-27946-1305728721-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 05-18 02:21, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 18 May 2011 01:10:46 +0200
>=20
> > Commit 7fee226ad239 (add a noref bit on skb dst) forgot to use
> > skb_dst_force() on packets queued in sk_error_queue
> >=20
> > This triggers following warning, for applications using IP_CMSG_PKTINFO
> > receiving one error status
>  ...
> > Close bug https://bugzilla.kernel.org/show_bug.cgi?id=3D34622
> >=20
> > Reported-by: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Applied, thanks.

Patch solves problem for me.

Initial warning was looking harmless anyway to me,
but good it is fixed now.

Thanks.
Witek

--=20
Witold Baryluk

--=_smp.if.uj.edu.pl-27946-1305728721-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk3T1s4ACgkQ7ZLFFOttZ4Jj3QCfW8hjFiajYZZ4OLUkrnSw+3QZ
Ql4An2JNtXCI+53MjYW9Hzqw9tm6mg39
=B6XN
-----END PGP SIGNATURE-----

--=_smp.if.uj.edu.pl-27946-1305728721-0001-2--
