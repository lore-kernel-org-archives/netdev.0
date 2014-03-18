From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Tue, 18 Mar 2014 18:27:52 +1100
Message-ID: <20140318182752.ed10b8c685f31839f84a1ece@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__18_Mar_2014_18_27_52_+1100__FTBvsVX+ur1_Ghr"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__18_Mar_2014_18_27_52_+1100__FTBvsVX+ur1_Ghr
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

net/netfilter/nft_hash.c: In function 'nft_hash_tbl_free':
net/netfilter/nft_hash.c:79:3: error: implicit declaration of function 'vfr=
ee' [-Werror=3Dimplicit-function-declaration]
   vfree(tbl);
   ^
net/netfilter/nft_hash.c: In function 'nft_hash_tbl_alloc':
net/netfilter/nft_hash.c:92:3: error: implicit declaration of function 'vza=
lloc' [-Werror=3Dimplicit-function-declaration]
   tbl =3D vzalloc(size);
   ^
net/netfilter/nft_hash.c:92:7: warning: assignment makes pointer from integ=
er without a cast [enabled by default]
   tbl =3D vzalloc(size);
       ^

Caused by commit ce6eb0d7c8ec ("netfilter: nft_hash: bug fixes and
resizing") from the net-next tree.  See Rule 1 in
Documentation/SubmitChecklist.

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__18_Mar_2014_18_27_52_+1100__FTBvsVX+ur1_Ghr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTJ/V8AAoJEMDTa8Ir7ZwVvS8P/ijEttj29F+BP9/NN6zbZCxb
NEmtZk9JFlmFsL4JSnidSuCfqys8oZvjXrd1FQ2xbMtGwhIHyovluE8IQ6TJrXVw
wL26ObjNQJLv3+8iNxD3bVBMMf+OmzZW9xLtu03ThNyN/6nFQi2/cm3aVP5YdZQo
WnOgR2SPRMj2Xd0Gd/9rQ+9THvL2eTQpWJkuY83Ud51H+Mbb5EdzYOFQsRXigpfn
8MNj2/1vp/Usm2DZOyd2Ri7kv4Jlpwm6LYmF7w1k0bH1JJSU8cejEJqnpqozC+ar
RNjNAsGETHdY4Ussf4YLch2N0H+3eukjqOoesjIEpIM1z2RuADHN577YhV6d/jCB
uM5uozub2KUgn7bN+gDbwMLgC9BPIouG9b0LfB/l0HgNb0LoY50czqTvA7rgfNuQ
z+mh2Hl+Vk37FRdLJ/xGdoxwCcpJGVhzVUwFwU17XfkISfg4R1p/uV5kTFWRSraw
RFXA/4LKExL2ILxpXCdGgUzCTlWrg4oIpG9QleCp9NoSs2Xc9IxulyfpQl7TOO2S
6/1V4+pZfqZnLniVc7w3n9et5+Tf2vL+kCM+KRpfY8nnJOaiZya1j6HWjxcksOaH
I2BgLITEfxeKOlb3kvJ2/N7Qz/PzDNvIQ/TisM+t3xCU/EOrL9Xt0/s42sa28l0K
pbXxDbHcMaAx/EZ8f9cq
=xGFF
-----END PGP SIGNATURE-----

--Signature=_Tue__18_Mar_2014_18_27_52_+1100__FTBvsVX+ur1_Ghr--
