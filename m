From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Fri, 21 Sep 2012 08:28:49 +1000
Message-ID: <20120921082849.693919e9a04431aed9e2461b@canb.auug.org.au>
References: <20120920173622.2aa7209cd241a3945f4384d4@canb.auug.org.au>
	<20120920091013.GV15548@intel.com>
	<20120920.164558.2281417114805373564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Sep_2012_08_28_49_+1000_I41RF1v=v_nKmmYs"
Cc: mika.westerberg@linux.intel.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	<linuxppc-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120920.164558.2281417114805373564.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Sep_2012_08_28_49_+1000_I41RF1v=v_nKmmYs
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 20 Sep 2012 16:45:58 -0400 (EDT) David Miller <davem@davemloft.net>=
 wrote:
>
> I think the powerpc port is at fault here.
>=20
> Part of being able to advertise ISA_DMA_API is providing isa_virt_to_bus(=
).

Not disagreeing, but it would be nice if this was documented somewhere
(maybe in Documentation/DMA-ISA-LPC.txt).  We have not had this problem
before because all the other uses of isa_virt_to_bus() are in drivers
that depend on X86 or ARM or ISA or EISA.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__21_Sep_2012_08_28_49_+1000_I41RF1v=v_nKmmYs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQW5ihAAoJEECxmPOUX5FEdHsQAKA/SCls+zDBV1Q3Pw8KTo5U
gawnFuCNNo5hQIfhXoY/o50OqbEp2An4CMAgTb8Ox/KoAq1Wk31Zn5thk7zdDT45
kGKOdVnlrDzqNd8zDwG8Jfbkvf+fZ3knpjblm1ySxBu48hQDbHI+ZEHjgyFKguRa
LP1vCs9zKN4kil4f1V2CPMpzehoFoHEz1LHLRocStIKeMQjm5w3ZlEolzn/MUOtT
7nBDSFpsWNwXlYcZh6P+ln7hMW5402ddu93A5hWzhzdddplXulD8K10DZBIP85zB
fO7kmcy01TZ5v83vy4E2hlX++EhrBPtGN08N3r6fMxT1Yf9fCxz0Ar+bI/vhOGpO
v0juToNesc/QTxm5sWUdSxUP6qrZFUtM426TUsslLbDsuYvX/gY+I/J38dxly8Nu
jr1I0FLY1ERvBFt0qfWn7w+ZNF2dIFQY3dSf0cC7jFXa+2ql+XNY7T1uziZWBj2X
n0B2eUkSsvmB06logXlyI9opR0tJfT4udgVquhv1YmtWCZOiAbbbJgRdwEgU/2BO
0AegZam+50jksHtIAjBqHV8sRKQSQjyJI9isNGd7i7Asp6vN7mCYqDfwtNSBCa5A
IAM3jyIkB1uP23nmFXXNlh2jwO015XJtO+T6ahBIuxTGz4oRo39x8AbSgCySYT9x
QQ+1keznyzq2iOLkDfGo
=9Gc5
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Sep_2012_08_28_49_+1000_I41RF1v=v_nKmmYs--
