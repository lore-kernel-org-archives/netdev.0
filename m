From: Valdis.Kletnieks@vt.edu
Subject: Re: tun routing is broken
Date: Sat, 05 Mar 2011 06:48:03 -0500
Message-ID: <5118.1299325683@localhost>
References: <20110304.010603.104076956.davem@davemloft.net> <4D70B2DC.2000005@gmail.com> <4D71EE86.6030309@suse.cz>
            <20110305.001022.183044112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1299325683_4963P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: jslaby@suse.cz, jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	netdev@vger.kernel.org, maxk@qualcomm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Sat, 05 Mar 2011 00:10:22 PST."
             <20110305.001022.183044112.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1299325683_4963P
Content-Type: text/plain; charset=us-ascii

On Sat, 05 Mar 2011 00:10:22 PST, David Miller said:
> --------------------
> ipv4: Fix __ip_dev_find() to use ifa_local instead of ifa_address.
> 
> Reported-by: Stephen Hemminger <shemminger@vyatta.com>
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/devinet.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 9038928..ff53860 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c

Confirming this fixes the problem I reported with IPv4 over PPP as well, thanks.


--==_Exmh_1299325683_4963P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNciLzcC3lWbTT17ARAkStAJ9DpYCYNqHJ6pZPvEjqgDwxM4RLOwCgxBgp
bEf6mJN17oDLNClP+WLBeUk=
=RDXm
-----END PGP SIGNATURE-----

--==_Exmh_1299325683_4963P--
