From: Thomas Schlichter <thomas.schlichter@web.de>
Subject: Re: [TEST_PATCH]Re: Fw: Oops in register_proc_table (2.6.1-mm4)
Date: Tue, 20 Jan 2004 00:51:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401200051.07144.thomas.schlichter@web.de>
References: <Pine.LNX.4.44.0401191146250.20265-100000@linux-udp15191261uds.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_r1GDAZaB+9HOpI8";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, KK <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>, akpm@osdl.org
In-Reply-To: <Pine.LNX.4.44.0401191146250.20265-100000@linux-udp15191261uds.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-02=_r1GDAZaB+9HOpI8
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Description: signed data
Content-Disposition: inline

Hi,

Am Montag, 19. Januar 2004 20:49 schrieb Krishna Kumar:
> Hi,
>
> Can you test with following patch ?

Yes, and it cures the Oops here!

> thanks,

Thank you, too!

> - KK

  Thomas Schlichter

> diff -ruN linux-2.6.0-rc2-bk6/net/ipv6/route.c
> linux-2.6.0-rc2-bk6.new/net/ipv6/route.c ---
> linux-2.6.0-rc2-bk6/net/ipv6/route.c	2004-01-19 11:41:14.000000000 -0800
> +++ linux-2.6.0-rc2-bk6.new/net/ipv6/route.c	2004-01-19 11:42:33.000000000
> -0800 @@ -1974,6 +1974,7 @@
>           	.proc_handler	=	&proc_dointvec_jiffies,
>  		.strategy	=	&sysctl_jiffies,
>  	},
> +	{ .ctl_name = 0 }
>  };
>
>  #endif

--Boundary-02=_r1GDAZaB+9HOpI8
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQBADG1rYAiN+WRIZzQRAnSIAJ9Dr9Rls6ORjAsXxROZDhs+Gjw7JwCZAXF9
mNVOLZef6gtVZE2xE0qy/f8=
=cRT8
-----END PGP SIGNATURE-----

--Boundary-02=_r1GDAZaB+9HOpI8--
