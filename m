From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] bluetooth: LLVMLinux: Remove VLAIS from bluetooth/amp.c
Date: Fri, 5 Sep 2014 16:22:16 -0700
Message-ID: <DBC61EBD-5FDE-48FE-8FD1-CA4F606C22F6@holtmann.org>
References: <1409958214-5651-1-git-send-email-behanw@converseincode.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mark Charlebois <charlebm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?iso-8859-1?Q?Jan-Simon_M=F6ller?= <dl9pf-Mmb7MZpHnFY@public.gmane.org>
To: behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409958214-5651-1-git-send-email-behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Behan,

> Replaced the use of a Variable Length Array In Struct (VLAIS) with a =
C99
> compliant equivalent. This patch allocates the appropriate amount of =
memory
> using an char array.
>=20
> The new code can be compiled with both gcc and clang.
>=20
> struct shash_desc contains a flexible array member member ctx declare=
d with
> CRYPTO_MINALIGN_ATTR, so sizeof(struct shash_desc) aligns the beginni=
ng
> of the array declared after struct shash_desc with long long.
>=20
> No trailing padding is required because it is not a struct type that =
can
> be used in an array.
>=20
> The CRYPTO_MINALIGN_ATTR is required so that desc is aligned with lon=
g long
> as would be the case for a struct containing a member with
> CRYPTO_MINALIGN_ATTR.
>=20
> Signed-off-by: Behan Webster <behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org>
> Signed-off-by: Mark Charlebois <charlebm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Jan-Simon M=F6ller <dl9pf-Mmb7MZpHnFY@public.gmane.org>
> ---
> net/bluetooth/amp.c | 13 ++++++-------
> 1 file changed, 6 insertions(+), 7 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
