From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 17/17] rds: switch rds_message_copy_from_user() to
 iov_iter
Date: Mon, 24 Nov 2014 02:00:18 +0000
Message-ID: <1416794418.7215.74.camel@decadent.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
	 <20141120214753.GR7996@ZenIV.linux.org.uk>
	 <20141120.182339.972861702759954603.davem@davemloft.net>
	 <20141121.122615.1091044030302005883.davem@davemloft.net>
	 <20141122042856.GZ7996@ZenIV.linux.org.uk>
	 <20141122043920.GQ30478@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ClvvWzAJDmUPsrm32NzH"
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	hch@infradead.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141122043920.GQ30478@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ClvvWzAJDmUPsrm32NzH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-11-22 at 04:39 +0000, Al Viro wrote:
[...]
> -		ret =3D rds_page_copy_from_user(sg_page(sg), sg->offset + sg_off,
> -					      iov->iov_base + iov_off,
> -					      to_copy);
[...]

It looks like rds_page_copy{,_from,_to}_user() are all unused after this
change, so you could delete them.

Ben.

--=20
Ben Hutchings
Absolutum obsoletum. (If it works, it's out of date.) - Stafford Beer

--=-ClvvWzAJDmUPsrm32NzH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHKROOe/yOyVhhEJAQrXNw/+JiKJ0QljIeeYF88W2Kpos+5VttSH2dy7
800FKXth2Wqhh2kjHFyPspsGbTt+acPxL/SpPu1SVbyC93jFEFQg7/49zoKUTgV7
CtrX981NHQFD9aXPJi/zspegYsDkdX83R7RcKd33Zu2M7GLAovVeV1smyqBAsmQ3
EDDf5L8eQRvIwvRI/dhqaqr4Oxb/sZUt4+PbBbapfShbnFz4dY8VGNSKV192mOqv
Rid0kVu7Tos7lMl1QodVfFO48acvSWjcWBslDtue+pNOFXJfw2ODAL4/JBptDjb9
rx4Lpxdo5dysc4YmHTsX45lMBfdosnzStdJkImh1gBn1S15zmQMY6Q23+2m0SIdD
STBwFX7Tk+nGnUeC2X5oHt7FRsRTBa4cytHVfe0lKoSRWy9Sl1ZsO8LU81CpS3Y+
ahC2hMdUaY6/MOvkWYNY/MT7SdInhx/UqZcefjMRVZOSBHGsc6UFW5Z34xLvGXK2
wGgOxDKrOGqnTpgqBBLF3G4YoplPAXglbLTo53H7ZRvAjUuZsdVOFrx5ydDFyk0N
CtdgloPR51o5FYx++NLQSzb3BpO1uilYUdFxbmhzqunlK3TM+G+F710157xgdRSo
8WLf5Q9zyGaSE1pj9AKeQvp/Hzen5DzTptxdoXsiSz4/T7AleelUN1b0/Rn7hv4Q
V3j863D8Jss=
=kgT5
-----END PGP SIGNATURE-----

--=-ClvvWzAJDmUPsrm32NzH--
