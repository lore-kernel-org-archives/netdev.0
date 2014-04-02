From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 3/4] ixgbe: clean up rx time stamping code
Date: Tue, 01 Apr 2014 18:45:54 -0700
Message-ID: <1396403154.2230.4.camel@jtkirshe-mobl>
References: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
	 <1396399939-18420-4-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cF7PV945VioBg9jscWBD"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53678 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757328AbaDBBqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 21:46:23 -0400
In-Reply-To: <1396399939-18420-4-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cF7PV945VioBg9jscWBD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-02 at 02:52 +0200, Jakub Kicinski wrote:
> Time stamping resources are per-interface so there is no need
> to keep separate last_rx_timestamp for each rx ring, move
> last_rx_timestamp to the adapter structure.
>=20
> With last_rx_timestamp inside adapter, ixgbe_ptp_rx_hwtstamp()
> inline function is reduced to a single if statement so it is
> no longer necessary. If statement is placed directly in
> ixgbe_process_skb_fields() fixing likely/unlikely marking.
>=20
> Checks for q_vector or adapter to be NULL are superfluous.
>=20
> Comment about taking I/O hit is a leftover from previous design.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 21 ++--------------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  3 ++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 36
> ++++++++-------------------
>  3 files changed, 15 insertions(+), 45 deletions(-)

Added to my queue, thanks!

--=-cF7PV945VioBg9jscWBD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTO2vSAAoJEOVv75VaS+3O3EwP/jYmtOCLpiQZIpLkGv3mqYwh
WC6vFkjuYNnaDTXEQwq+HIoK+DBvvtxTRj9EhDK7jM8eVKtJd2jNthYRdpYnaqRt
qisVkUmwbBy/Kx0aZArsu0vrrPwq+yOIDH/BwMAOEJuXKhUIJgZ+MMYDgC1pjNXR
RIqEpF5dQXHPYuB1v/fgzP19rMBybM88XoH0PY312RlGEOk2Cui+6Puk0bQmrULi
xMKffUPDItNDW70FObEP1an1x5sl+lwhZI1WpmjNQeCmRRQBs4iRPSTehub51hR9
uwHlOcQLGjcz8kgi9y3SyKEWpzTBTXZH+nFm5sVFzeuD6PYO/yEgf3+Y89tM9LlB
PqKddUjZRZGYHChLFlplpJYZmt3zNEYfIjFKyo02tLHgOSBs/06sHd1Z+bowZ3WF
o1zqIWdSsV8MxewWD7YMKJ+ENGbFXHPFaxZx2ArK/2nEsKhk1JC/OhH8FGKYzqbK
/hwV4tqxg/7SnBtvBNYj5HvdDuWyMCQDprlRFJFX9K1TvyRq7W2hmNEUQjtw5dUK
gqmbjzxoshoU7SYaAm09qcTNLct9rjkTBm3GoGdOmsw90AKwIgR3NktIFvFYb4l+
NSzLxiiGHHyWgQiZJP2qCeNVbTpKMiY6h5pI6QulHyIWISFzsTx9pv+tdkEhPc8O
zJR6IvuMMlL4Q0jwXQv0
=hMZA
-----END PGP SIGNATURE-----

--=-cF7PV945VioBg9jscWBD--
