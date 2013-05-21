From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next
 tree
Date: Wed, 22 May 2013 09:54:36 +1000
Message-ID: <20130522095436.66e63c613c41da01cd103208@canb.auug.org.au>
References: <20130521142537.00a9ccb7ca4aa81f553b61cf@canb.auug.org.au>
	<519B25CD.5060801@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__22_May_2013_09_54_36_+1000_0TExivfAl2d=7F9o"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Schichan <nschichan@freebox.fr>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519B25CD.5060801@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__22_May_2013_09_54_36_+1000_0TExivfAl2d=7F9o
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Daniel,

On Tue, 21 May 2013 09:44:13 +0200 Daniel Borkmann <dborkman@redhat.com> wr=
ote:
>
> Also seccomp_jit_free() needs a change otherwise the kernel won't build
> with CONFIG_SECCOMP_FILTER_JIT enabled since the work_struct is initializ=
ed
> with the bpf_jit_free_worker() callback, which is no longer existent.
>=20
> Do you want me to send you a patch?

Yes, please.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__22_May_2013_09_54_36_+1000_0TExivfAl2d=7F9o
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRnAlAAAoJEECxmPOUX5FEp/0QAJAoFRXOZKc0tIn1kcPdgf1f
iFQw8PZmE8VB+lC6SzmqfPs0nuFHG1TPMhfFLJaLw91jDdw+E9sgIN3bnm3gaerG
JbwN4zzfygv5Aa3w+1Z8aDrVPYZAqKSheMPRRzxejeJ0RXiy3scQ6HZBv1U8rXhy
jk/QdCj7vtGbKgnoEbKuo4EBdX/LayKMOC4RMn3TaIu6yCXlOPfgIcjNXaCedPT/
gqslM6VTDHg/KpZ4mojMog+j5IB9YSpJGFMTqBLG3NJiCKwC3hHsi0sGtsV98ocw
m1eWnUJTr4oa0xyKNOqXkVtCtD33JdteobpPA6tW7WfAJxW95Yt61TV5SEs3eI4S
nJ8wbROtcTDmEoxp4e8pBHI/GBpqqj8RAZB5n/yJleWWWOK4O9WIXsaIcHm8+Dji
OK4LNEOApkAkEO54gxZFRGzNSQYIPFRCeBizD/qH1d1dh45CeXZXqSj5T6gjpQFw
j53inMbDF5+E8FCKXmoZI1CbWRwKferUl8KchvqEZf6+dkbA2XABgsYLTLNDudCO
k76H14on3tcZJRxVTfke2DR8rfQCr269omcaKcS955cU/qirfjjoB7431Ea2me8W
FWuZaqGIZW4wthMnnXZmPH2q1LI7q8A7kx2MWAT/BdKEfaOhgLCc62llQr0C7rd8
pKXfN/62L9rX3za0DoQT
=0Xwa
-----END PGP SIGNATURE-----

--Signature=_Wed__22_May_2013_09_54_36_+1000_0TExivfAl2d=7F9o--
