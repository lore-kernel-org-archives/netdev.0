From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Tue, 16 Aug 2011 15:28:15 +1000
Message-ID: <20110816152815.911f15937efa2ebf58a2795d@canb.auug.org.au>
References: <20110815152048.3b8f8484faf1891ef2fce266@canb.auug.org.au>
	<20110814.225610.2264854100578866902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__16_Aug_2011_15_28_15_+1000_w/bm/oAUeVlFW6dS"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110814.225610.2264854100578866902.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__16_Aug_2011_15_28_15_+1000_w/bm/oAUeVlFW6dS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Sun, 14 Aug 2011 22:56:10 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> This should fix the include problem, but I suspect this thing won't
> link.

Yep, indeed, today I get:

make[5]: *** No rule to make target `drivers/net/ethernet/toshiba/ethernet/=
sun/sungem_phy.o', needed by `drivers/net/ethernet/toshiba/built-in.o'.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__16_Aug_2011_15_28_15_+1000_w/bm/oAUeVlFW6dS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOSf/vAAoJEDMEi1NhKgbszLkH/1R8mgQNzW2Gp4+8v3zvbVoK
NFAxaJJ8AjqOvnWIa1SX3a5KryO7VCGo6UOyjTwsa44RQaKv9LoYWtljFE1rriCx
Vc6tyMAZWL/oivwB+VaUXHuKfTFwNUtneY5KA5ipGVeSdw8B4EQ0nM/USr5RUv7a
qnsCgnolrR/BVDAo68AEfOQ/VzW5MmdDP3pXuzce8A+8rRC3EFNMBvqf2Pp1FJin
HjtSW7dVpeZsvtz9EVJvWeJ6amef8LkffKJSfBRaPSO3WASzegNpGzqmhjGnFf3i
yTxCKxpNL0bGK5mQAdNicANk9yPyDMffYOxAW+TdvsNU0wxY4qitiAA89DhSE6A=
=cB3a
-----END PGP SIGNATURE-----

--Signature=_Tue__16_Aug_2011_15_28_15_+1000_w/bm/oAUeVlFW6dS--
