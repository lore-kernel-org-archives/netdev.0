From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] Re:[BUILD FAILURE 04/04] Next June 04:PPC64 randconfig
 [drivers/net/ucc_geth.o]
Date: Thu, 11 Jun 2009 11:05:23 +1000
Message-ID: <20090611110523.1fd56a41.sfr@canb.auug.org.au>
References: <20090610174323.28045.70169.sendpatchset@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__11_Jun_2009_11_05_23_+1000_CLhLW3vWD/LT16B1"
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>
To: Subrata Modak <subrata@linux.vnet.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090610174323.28045.70169.sendpatchset@subratamodak.linux.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__11_Jun_2009_11_05_23_+1000_CLhLW3vWD/LT16B1
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Subrata,

On Wed, 10 Jun 2009 23:13:23 +0530 Subrata Modak <subrata@linux.vnet.ibm.co=
m> wrote:
>
>  	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
> -	ph =3D of_get_property(np, "tbi-handle", NULL);
> +	ph =3D (phandle *)of_get_property(np, "tbi-handle", NULL);

You don't need this cast because of_get_property() returns "void *".

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__11_Jun_2009_11_05_23_+1000_CLhLW3vWD/LT16B1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkowWFMACgkQjjKRsyhoI8w4TQCdFUiVJxuhoNJri0/mjfdAhFy/
Dn4AniZX+xHe8/kuLRQt7+OruyVHTcOv
=y6+w
-----END PGP SIGNATURE-----

--Signature=_Thu__11_Jun_2009_11_05_23_+1000_CLhLW3vWD/LT16B1--
