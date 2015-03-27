From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH net-next 7/7] igb: Enable TSO for stacked
 vlan
Date: Thu, 26 Mar 2015 21:48:52 -0700
Message-ID: <1427431732.2497.48.camel@jtkirshe-mobl>
References: <1427346080-12086-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1427346080-12086-8-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MWogQtuFgFWcXbxhdrxH"
Cc: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Linux NICS <linux.nics@intel.com>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53649 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbbC0Es4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 00:48:56 -0400
In-Reply-To: <1427346080-12086-8-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MWogQtuFgFWcXbxhdrxH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-03-26 at 14:01 +0900, Toshiaki Makita wrote:
> As datasheets for igb (I210, I350, 82576, etc.) say, maclen can be
> from
> 14 to 127, which is enough for reasonable number of vlan tags.
> My netperf test showed I350's TSO works pretty fine with multiple
> vlans.
>=20
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 1 +
>  1 file changed, 1 insertion(+)



--=-MWogQtuFgFWcXbxhdrxH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVFOE0AAoJEOVv75VaS+3OwKEP/0oa3M3eOK3BV012+BqlbOsb
OJjLWgWCkpdQhW/NdYgBwx+4CSQKnna+4IC28gzFETQk1C0RL4DTCCNLugC6Rpw6
K7D77s9oZ80GUkACz+xN5NiE6bRCGADhYXR7kjUbv2S9uDGaW2ooXPaeU/G/yzmV
t1zFq0sqEyV1EH242ssTTprbVRvHsjNcBpKWAIv/TXAaKCpXLz8vXGTrWyaFVL9Q
9T6/VlwfTfGvEelCf9Gps85y/4VP+gBRQnb/cwS07sS4AfvC+si409s4t8PSofgk
Ax2e2J3zRwKk95iRmgpxmG+qJtftD+fds+631hWARi8qTqUrG8u2Q/KbclQzoJuw
18ddIbE0Vquqv7xQiw6UR1wle6f8ZqmUHrdBLWUtgC0pcK4wBPaNonyAQKpJVwKS
NE3RSXDR9Ypk8pNMbdZowREZ1wGj6B5Vm7S5Bq0HZ8PAofmOlLrxmwndsxMj3it/
mImgfkMyCh+59NnogwlYGc+p89b5vhPvrU960etBfLH78fQGmoyI4izjbY5nPjHb
uO5wcSGGPs80Mw+iZSqxW9I8cGSuf4qJqwbcgY9+XmmPt0vDnrIbWt12HyE/kPLs
wV2v1N6DSTDhXh+SFqfTSsQUNwChoDV614SUNWx9krZ3oPgk+ooPCfcaXvLJ3wGF
hjoG4PB3kOu+TAKU+GhP
=wzC5
-----END PGP SIGNATURE-----

--=-MWogQtuFgFWcXbxhdrxH--
