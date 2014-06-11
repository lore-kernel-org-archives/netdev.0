From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 12/15] i40e: remove Tx work for ptp
Date: Wed, 11 Jun 2014 13:56:42 -0700
Message-ID: <1402520202.2336.7.camel@jtkirshe-mobl>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1400673673-31626-13-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJZOPZJRjZ+od4-obYJfGbzTT0W1nRfCZvWeWa1VZbTD2vLdTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Yi/KyTR/RFH3KCnNmF8b"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18152 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471AbaFKU4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 16:56:43 -0400
In-Reply-To: <CAJZOPZJRjZ+od4-obYJfGbzTT0W1nRfCZvWeWa1VZbTD2vLdTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Yi/KyTR/RFH3KCnNmF8b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-05-27 at 10:51 +0300, Or Gerlitz wrote:
> On Wed, May 21, 2014 at 3:01 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> >
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >
> > The previous removal of the PTP Tx work functionality was
> > incomplete as noted by Jake Keller. This removal allows
> > us to rely on the Tx timesync interrupt.
>=20
> This patch removes a define of  I40E_PTP_TX_TIMEOUT and stats entry
> for
> tx_hwtstamp_timeouts, I am not sure to see how this removal allows the
> driver to
> rely on the Tx timesync interrupt, maybe wrong change-log?

Sorry, you are correct it was change-log mistake.  This was follow on to
the previous:
Commit 0dd8357f8fab1d82aa8fc8267261203f393d5a1f
Author: Jacob Keller
Date:   Wed Jan 15 08:38:35 2014 +0000

    i40e: remove ptp_tx_work timestamp work item

which implemented the work to allow us to rely on the Tx timesync
interrupt.  This patch was just finishing up the cleanup of code which
we did not need any longer because of the conversion to the transmit
timesync interrupt.

--=-Yi/KyTR/RFH3KCnNmF8b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTmMKKAAoJEOVv75VaS+3OIIIP/09pHzsPwo35Ph70aI5ctDMH
E2EsVkWOXTFZlpSGW0YY1W3MTN8VmsWiCLMWoic8rQDf7ZWEKMSNVTMo8hJ8Gs5E
VvezvDXwoP6ZQL/b/BWTtaZnFXE0iWzsauZePK1W8YLj5U86aY3wTS6dvsyeNWd4
0wBfN6olMomQDiTmVfyZmO8AgIEJmP0ymHgVlaE64PefbbODBoha0jbqmyFDso6d
EUnIsFPrXr7+fFUpD64h6Sno2WTNGhPxapl7qr6ib0Mgd6GxdHIaDprO9B9dEsfn
hBV0medOGamqov0dDmiKXSH+trKRY7TS4QZfrrMdJmJ7utGR3HL1cMkuCbHiTyT4
XJZrE2+UT5aaSZWF+AWmNIXUreSiUnR8hIiU2D1yVZm866dk9WLvJrumD+5LCGPG
RWvHuGhvdfOP/EDGa8s68fRkor0CHSFZJZB1OXX5D9RYZAm929I0mddDhs7/Vo+r
W6txm+gxw6bMGTiXEIhlU3CtWI5+g5ai6urlnuN/zCoZCaExk6YfKtd6r2hpvzFu
oiSWP4RrGpI/wxk0K8TjltjzfX5P/Bd9Kd1zSQxnHAJsZ4gv0sKJLrJI5iBehrp+
iUzKDHOTb1ZnmrpKBbg4T0qvZloy2Uxat/+A0rTLnnXfHOztO5DRx/VsUEWckfRO
y9+rHkYkoHDA7vpCIVp9
=WfB6
-----END PGP SIGNATURE-----

--=-Yi/KyTR/RFH3KCnNmF8b--
