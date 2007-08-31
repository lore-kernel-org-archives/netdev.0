From: Athanasius <link@miggy.org>
Subject: Re: [Bugme-new] [Bug 8961] New: BUG triggered by oidentd in netlink code
Date: Fri, 31 Aug 2007 13:38:25 +0100
Message-ID: <20070831123825.GW22067@miggy.org>
References: <bug-8961-10286@http.bugzilla.kernel.org/> <20070830180842.7c8414fe.akpm@linux-foundation.org> <Pine.LNX.4.64.0708311258520.8423@x2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eMP3JyRexyk9c0Bv"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, link@miggy.org
To: Patrick McHardy <kaber@trash.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fysh.org ([83.170.75.51]:34650 "EHLO bowl.fysh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965045AbXHaNdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:33:22 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708311258520.8423@x2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--eMP3JyRexyk9c0Bv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 31, 2007 at 01:05:04PM +0200, Patrick McHardy wrote:
> Seems to be a bug introduced by the netlink_run_queue conversion,
> since there is no locking and netlink_run_queue doesn't check
> for NULL results from skb_dequeue, it might pass NULL to
> netlink_rcv_skb, which crashes.
>=20
> Does this patch help?

  I'll compile up a new kernel, likely 2.6.22.6, plus this patch, and
reboot to it tonight.  I still don't know *exactly* how to trigger the
bug on demand though, it's not reocurred since I posted the bug report
(but had happened about a week before as well).

thanks,

-Ath
--=20
- Athanasius =3D Athanasius(at)miggy.org / http://www.miggy.org/
                  Finger athan(at)fysh.org for PGP key
	   "And it's me who is my enemy. Me who beats me up.
Me who makes the monsters. Me who strips my confidence." Paula Cole - ME

--eMP3JyRexyk9c0Bv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFG2AvBIr2uvLNOS8MRAtnKAJ4zRabYY7lO1UuKACAe2Cr2tvQ9AACeOntv
9ccxGRDbO5AoBPshVsJHweg=
=nF3G
-----END PGP SIGNATURE-----

--eMP3JyRexyk9c0Bv--
