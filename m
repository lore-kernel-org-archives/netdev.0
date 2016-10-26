From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH 25/27] igb: Update driver to
 make use of DMA_ATTR_SKIP_CPU_SYNC
Date: Wed, 26 Oct 2016 10:21:05 -0700
Message-ID: <1477502465.2431.0.camel@intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
         <20161025153900.4815.4927.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-Bz3DXNO8vagssa5nt9XQ"
Cc: davem@davemloft.net, brouer@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161025153900.4815.4927.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Bz3DXNO8vagssa5nt9XQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-10-25 at 11:39 -0400, Alexander Duyck wrote:
> The ARM architecture provides a mechanism for deferring cache line
> invalidation in the case of map/unmap.=C2=A0 This patch makes use of this
> mechanism to avoid unnecessary synchronization.
>=20
> A secondary effect of this change is that the portion of the page that
> has
> been synchronized for use by the CPU should be writable and could be
> passed
> up the stack (at least on ARM).
>=20
> The last bit that occurred to me is that on architectures where the
> sync_for_cpu call invalidates cache lines we were prefetching and then
> invalidating the first 128 bytes of the packet.=C2=A0 To avoid that I hav=
e
> moved
> the sync up to before we perform the prefetch and allocate the skbuff so
> that we can actually make use of it.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>=C2=A0

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
--=-Bz3DXNO8vagssa5nt9XQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYEOYCAAoJEOVv75VaS+3OThIP/1kAA/z9SkIY3MCl4/5V4qRJ
j7c6VCJFFF9dHScb2zeJ8lJRC3NTjZDmm4A8Pfeg8nNZwkDteuxCVViUWONkIU3E
Uy3JUcdoTnGG/O43JtQEna9oAeWTrBNALiMvx33HY/TQ9BlviJ2w7jlo+Snlv3aH
KMnYVUslQJJov+HuEaGenzdziElLPvrkVrZEYesOKd+zQ8A+0uuOYOlhRINayM36
rEMPUl8xOmpIvLy0Zf2u9s8BL8LvPoitGdm+F1wqRK3ut4lfTs+q2kUQ8ElzBcp1
w0aYwpj+m6WDdijoGyW0HqeWhMSHp7MCLHx7801PnU1nFKb5A5lAYq02pUVkW8fp
ZLuQoENTlcfQRDRn0OCxc4J3EDwsGKGyjbZgmj158Ye3q7hVfPJefJKCOJRv9TQt
pR0CS3A9fyixUhzGexAaOBoE0KO2G14YBshBfOgiOOYwlxLWA+rcHwSZ2HCJ/ZfY
pcr4IqWI7l5Ju1XO8xD8vOWsu4yy6igIAQNuOvxjuNfSzIgX5SmkbGc4h1VNoNXH
AUb8ZKof5JucQwAv89bi3DeXuDw6kkS7jrEzKNABootiVl0PcvtV0nS2eRWmUqg3
h/pIBCA1+aozA7nZIBU9OzeM7Bfr5F5UeUYihxGTQBe46+s8mmgaUyWAdTGPcZEm
14UaX7dQ+Sl7klVAfmeU
=qP1+
-----END PGP SIGNATURE-----

--=-Bz3DXNO8vagssa5nt9XQ--
