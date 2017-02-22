From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: Re: [PATCH] uapi: fix linux/if.h userspace compilation errors
Date: Wed, 22 Feb 2017 05:22:59 +0300
Message-ID: <20170222022259.GA32359@altlinux.org>
References: <20170220115841.GA6846@altlinux.org> <20170221.121022.676021611021776681.davem@davemloft.net> <20170221201914.GA28360@altlinux.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=x-unknown;
        protocol="application/pgp-signature"; boundary="HlL+5n6rz5pIUxbD"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170221201914.GA28360@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 21, 2017 at 11:19:14PM +0300, Dmitry V. Levin wrote:
> On Tue, Feb 21, 2017 at 12:10:22PM -0500, David Miller wrote:
> > From: "Dmitry V. Levin" <ldv@altlinux.org>
> > Date: Mon, 20 Feb 2017 14:58:41 +0300
> >=20
> > > Include <sys/socket.h> (guarded by ifndef __KERNEL__) to fix
> > > the following linux/if.h userspace compilation errors:
> >=20
> > Wouldn't it be so much better to do this in include/uapi/linux/socket.h?
[...]
> We can try to workaround these ancient <time.h> against <linux/time.h>
> and <sys/uio.h> against <linux/uio.h> conflicts on uapi side by
> introducing __UAPI_DEF_TIMESPEC, __UAPI_DEF_TIMEVAL, and __UAPI_DEF_IOVEC
> guards, but these workarounds will work only one way (when libc headers
> are included before uapi ones) until glibc catches up, and the latter
> may take a lot of time.

OK, these conflicts need to be fixed regardless of the way how
struct sockaddr related uapi compilation errors are fixed.
I'll submit these fixes shortly.


--=20
ldv

--HlL+5n6rz5pIUxbD
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYrPYDAAoJEAVFT+BVnCUIazsP/1IzXyojBe8PXiIkpajYRuXl
D1bPqhAnvG9KAGFjHBShvN0N8YfVaj9PJftviwTU4qfsRXxiDbv4ZBOfVvj8jul1
2Lwy/CoElhUDeOMMz0KkKw3x53AXo0vbEVjW+x39WrcDMrkJA7m9bBnHxMT0Exd9
u/9R3lhA9K1/BzuJOfxE0Ky4UYnmm0UeUPM6QZ86MH/5ltTMzIiqW+eaII7Q/yeN
5YtScM/OzZAdrin9lRKgVR8ZbrSrInU2UNlSNVbITCdL7CrVfJW855CFa3s1sv6i
bQIV0z4tB7OX7Q9JNgY2sQOHAS4R3vl0e0zpYUmhFFcIjC/LU3bq7yxo3tKtHI6m
h9c1jKNG+O0eE2EfrVPM4FayYuFe3McII9MCR0sAQHSf6cZAFBTdBEr7Cdl5HqKa
sair7ag5oVoHmGa2FtbSHRXeWdV58ZvlDUhMDFVIXnXtnr61Liu9smz45DO+jKyy
VPRUdH/dejU82DyKW4ToIAG10kMI1YWJOXXF8Fbt5/STlP5KUwAEUJOAJgF4JgKf
IWwQEMSTdBKo6NuNgH7lqRE5YyHRiwRvMXrWPodfSPke0eO8scLF/oIt4EcdLItx
xxAnHznd/SMMMlvgSWSE5dKgxSi4TWpDXSxzcnxdhqwrLt5SHK0bcOX2yKbv5xgH
+tIl4rVBCrpRjDNFQsPg
=jVDj
-----END PGP SIGNATURE-----

--HlL+5n6rz5pIUxbD--
