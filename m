From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 02/10] e1000e: add timeout for TX HW time
 stamping work
Date: Fri, 14 Mar 2014 16:20:31 -0700
Message-ID: <1394839231.2167.96.camel@jtkirshe-mobl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	 <1394818481-7652-3-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wFYr6M5V+yo+LN6MpTzb"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36039 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754791AbaCNXUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:20:33 -0400
In-Reply-To: <1394818481-7652-3-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wFYr6M5V+yo+LN6MpTzb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> Hardware may fail to report time stamp e.g.:
>  - when hardware time stamping is not enabled
>  - when time stamp is requested shortly after ifup
>=20
> Timeout time stamp reading work to prevent it from
> scheduling itself indefinitely. Report timeout events
> via system log and device stats.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/e1000e/e1000.h   | 2 ++
>  drivers/net/ethernet/intel/e1000e/ethtool.c | 1 +
>  drivers/net/ethernet/intel/e1000e/netdev.c  | 7 +++++++
>  3 files changed, 10 insertions(+)

Thanks Jakub, I will add this patch to my queue.

--=-wFYr6M5V+yo+LN6MpTzb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTI46/AAoJEOVv75VaS+3OObAP/0i5iOuR00j3UGU5rn+fR0T8
1HcLr2KVMkHANjzCS7vs8tf1XttxGRLCTz1prcMRiVhTZcMInXnhYkXPQDcwiiQa
5tMNnqCdHo1246Jinj+x/bINMmdhD8MpjYdj/trGadCYZETTpq8TTN6YwxiP6Ymu
sXCi24sIIoCHIwIZe87jIoJHh5ZhlAHVTOlI9ASDbpPRA1rhbQs6iFbzSRQ333mt
MTviEREvBXoGIw4qaeNivtGmkS/5GRq6ZWCkEPY1FR365kiUUnL556YIHAzuvs4U
788YA2RfAtPDzs2D+ytC+Znz5NEy38ufiB7Sb4t04tm4JZRgZEUajW9aY5XpAy4I
zFXLVcPejNmLo3MbI+HIiDhISuMZE0O9r4MiFuwlUdSdt4b4CWjJiYpXoc5VrahB
AJGQkUCHB/U+/brhB5Z3a4ErLzejd05zeQwr0bcj22a2DGRiiPppQIAdfMzZCXwi
Jf2xznYlyMvd8/46qru+KZRV+TnrJO8qhW0sOXbjYKdWlarZ4YdR6wv0ol8vQLkQ
v+kk+1+kztpt3/dyJL5B2GO/PE96p9gIPpiBz0Qz5sFOerIZaTxbu+jdMvlMxyOY
ehxeAKFRDDbmIKNCRirR5dQMJZ0bpwbk37lEg1dyG93mhL18VXA7gPAOXcWjH4Ms
MhmoD4Hh3kkiuhstdxM+
=TwyG
-----END PGP SIGNATURE-----

--=-wFYr6M5V+yo+LN6MpTzb--
