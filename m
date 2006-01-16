From: Stuffed Crust <pizza@shaftnet.org>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 16:06:26 -0500
Message-ID: <20060116210626.GA15495@shaftnet.org>
References: <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost> <20060114011726.GA19950@shaftnet.org> <43C97605.9030907@pobox.com> <20060115152034.GA1722@shaftnet.org> <Pine.LNX.4.58.0601152038540.19953@irie> <20060116170951.GA8596@shaftnet.org> <Pine.LNX.4.58.0601162020260.17348@irie> <20060116190629.GB5529@tuxdriver.com> <Pine.LNX.4.58.0601162210550.17348@irie>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
Cc: "ext John W. Linville" <linville@tuxdriver.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751206AbWAPVGx@vger.kernel.org>
To: Samuel Ortiz <samuel.ortiz@nokia.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0601162210550.17348@irie>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 16, 2006 at 10:16:06PM +0200, Samuel Ortiz wrote:
> Well, I'd rather trust a governement regulated network than my neighbour's
> AP ;-) In fact, some phones set their 802.11 regulatory domain based on
> the information they received from a somehow government regulated network,
> e.g. a GSM one.

The asumption is that 802.11d information, like current "regdomain"
settings, is fixed and not user-configurable.  If the regdomain is
changeable by the user, that unit would not be approved for sale in that
particular locale.

(Now 802.11d doesn't specify what to do when you hear two conflicting=20
 802.11d beacons.... there go those assumptions again..)

Stations respecting 802.11d rules are not allowed to transmit on any
supported frequency until they hear an AP on that frequency first. =20

This essentially means that all scans are passive until we hear an AP,
and we can't transmit on any other (presumably still silent) frequencies
unless we hear an 802.11d beacon that says we can.

 - Solomon
--=20
Solomon Peachy        				 ICQ: 1318344
Melbourne, FL 					=20
Quidquid latine dictum sit, altum viditur.

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFDzArSPuLgii2759ARAqx7AKCeOtC9h+zdwU5L9KozsoT4ZUgAcgCeIkT2
APaXfKBDnDXQ32wi7IeS4/s=
=/Oyl
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--
