From: David Gibson <dgibson@redhat.com>
Subject: Re: [RFC 3/4] tuntap: reduce the size of tun_struct by using flex
 array
Date: Mon, 25 Aug 2014 11:35:11 +1000
Message-ID: <20140825113511.cc52779b6c2f13c9abef23ee@redhat.com>
References: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
	<1408369040-1216-4-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__25_Aug_2014_11_35_11_+1000_+OyL/QXpMUHP80Iz"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, wuzhy@linux.vnet.ibm.com, xemul@parallels.com,
	therbert@google.com, bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408369040-1216-4-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__25_Aug_2014_11_35_11_+1000_+OyL/QXpMUHP80Iz
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 18 Aug 2014 19:07:19 +0530
Pankaj Gupta <pagupta@redhat.com> wrote:

> This patch switches to flex array to implement the flow caches, it brings
> several advantages:
>=20
> - Reduce the size of the tun_struct structure, which allows us to increas=
e the
>   upper limit of queues in future.
> - Avoid higher order memory allocation. It will be useful when switching =
to
>   pure hashing in flow cache which may demand a larger size array in futu=
re.
>=20
> After this patch, the size of tun_struct on x86_64 reduced from 8512 to
> 328
>=20
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>

Reviewed-by: David Gibson <dgibson@redhat.com>

--=20
David Gibson <dgibson@redhat.com>

--Signature=_Mon__25_Aug_2014_11_35_11_+1000_+OyL/QXpMUHP80Iz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJT+pLPAAoJEGw4ysog2bOSDY8QAJ/0tFaq4J0GUXknB4+4z7Z7
asmSKDqtQD9oVKiaXjM39zd76cdfEuX0ZIXsRpqjU3mJ8EMNub82jBp51BN/PGjb
8WyponHG30gMXBCgw6Vpdf1IQrQEJisifSWQtB1ASkMbTU3+/gWCTUza8NbAkCmK
XlfSkObBuQJN73YcBh0zY5AbhjfqAF3G2i+1Jf3+taj8PbyxbNCvtyDaYA8Qkf+t
gvSeAFBw12rZDA/PMd37nyC727M2mfZTi5FVwuCxIpC/kQAxgvhARhGWckQFv6A5
U6dUsWPXDr3TpA1/x+pS4tErugqyMC9YbO89Je8xl1aV50xeydvcc6umbeL0saUf
kSsU0JU/PZMZreIHO8ZRNK3LDp+NSFXgna+IOjrd6CHTOYjxnk28iMfxk0MgRCIz
lvkFqmTB3+arZQq69+2xuVa8TH1gOqWtOp3zhzPYaDmRP4Jy5KDbMDk7n6NuLiaf
YyaMM4Oz5v4cwfX+m/ES63HQmD9CoVZWn/3HLdGT+Uatiy4Ywq0KlQkR0zS5o0nv
UeOWA5fC8pmJ93Q2Rr0CAJpVS3zoJmgPyh07+xnZ90fU/HFfbU5gAHtXuHyBD70d
mEjVhDPpmBXZfGbGVT/gIPozd9Hlsas3GuDbfK2sf0UK9Y9tbUlrsL10kYQ3sEm3
DNXtFDhoaoCrgjBpp/lC
=/GtQ
-----END PGP SIGNATURE-----

--Signature=_Mon__25_Aug_2014_11_35_11_+1000_+OyL/QXpMUHP80Iz--
