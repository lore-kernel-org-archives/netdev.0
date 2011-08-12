From: Valdis.Kletnieks@vt.edu
Subject: Re: TCP port firewall controlled by UDP packets
Date: Fri, 12 Aug 2011 12:40:34 -0400
Message-ID: <6556.1313167234@turing-police.cc.vt.edu>
References: <1313106969-18733-1-git-send-email-as@strmilov.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1313167234_2634P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tonda <as@strmilov.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Fri, 12 Aug 2011 01:56:09 +0200."
             <1313106969-18733-1-git-send-email-as@strmilov.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1313167234_2634P
Content-Type: text/plain; charset=us-ascii

On Fri, 12 Aug 2011 01:56:09 +0200, Tonda said:
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -624,3 +624,7 @@
>  	  on the Internet.
>  
>  	  If unsure, say N.
> +
> +config TCPFIREWALL
> +	tristate "TCP Firewall controlled by UDP queries"
> +	depends on m

I don't suppose it would be asking too much to support UPNP here, would it?
https://secure.wikimedia.org/wikipedia/en/wiki/Internet_Gateway_Device_Protocol

(If this in fact *does* do the UPNP thing, then this *really* needs better docs).


--==_Exmh_1313167234_2634P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFORVeCcC3lWbTT17ARArKFAKCYJ+Eq1gVGp+7tcrQFTpz6cF1WrwCg+4/U
BXGIxPr7tXpJbXcx5TZF6Kk=
=6ULu
-----END PGP SIGNATURE-----

--==_Exmh_1313167234_2634P--
