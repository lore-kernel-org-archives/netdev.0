From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 00/12] radix-tree: split out struct radix_tree_root out
 to <linux/radix-tree-root.h>
Date: Sun, 8 Oct 2017 21:52:33 +0300
Message-ID: <20171008185233.GF25829@mtr-leonro.local>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="O9uFcEIpmYvy18ul"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Ian Abbott <abbotti-GUHe90Wt2aFaa/9Udqfwiw@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        linux-cachefs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rodrigo Vivi <rodrigo.vivi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, David Airlie <airlied-cv59FeDIM0c@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Yoshinori Sato <ysato-Rn4VEauK+AKRv+LV9MX5uooqe+aC9MnS@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Rich Felker <dalias-8zAoT0mYgF4@public.gmane.org>,
        Jani Nikula <jani.nikula-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
        Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Joonas Lahtinen <joonas.lahtinen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
To: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1507479013-5207-1-git-send-email-yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--O9uFcEIpmYvy18ul
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 09, 2017 at 01:10:01AM +0900, Masahiro Yamada wrote:

<...>
>
> By splitting out the radix_tree_root definition,
> we can reduce the header file dependency.
>
> Reducing the header dependency will help for speeding the kernel
> build, suppressing unnecessary recompile of objects during
> git-bisect'ing, etc.

If we judge by the diffstat of this series, there won't be any
visible change in anything mentioned above.

<...>

>
> Masahiro Yamada (12):
>   radix-tree: replace <linux/spinlock.h> with <linux/spinlock_types.h>
>   radix-tree: split struct radix_tree_root to <linux/radix-tree-root.h>
>   irqdomain: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
>   writeback: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
>   iocontext.h: replace <linux/radix-tree.h> with
>     <linux/radix-tree-root.h>
>   fs: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
>   blkcg: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
>   fscache: include <linux-radix-tree.h>
>   sh: intc: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
>   net/mlx4: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
>   net/mlx5: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
>   drm/i915: replace <linux/radix-tree.h> with <linux/radix-tree-root.h>
>
>  drivers/gpu/drm/i915/i915_gem.c            |  1 +
>  drivers/gpu/drm/i915/i915_gem_context.c    |  1 +
>  drivers/gpu/drm/i915/i915_gem_context.h    |  2 +-
>  drivers/gpu/drm/i915/i915_gem_execbuffer.c |  1 +
>  drivers/gpu/drm/i915/i915_gem_object.h     |  1 +
>  drivers/net/ethernet/mellanox/mlx4/cq.c    |  1 +
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h  |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/qp.c    |  1 +
>  drivers/net/ethernet/mellanox/mlx4/srq.c   |  1 +
>  drivers/sh/intc/internals.h                |  2 +-
>  include/linux/backing-dev-defs.h           |  2 +-
>  include/linux/blk-cgroup.h                 |  2 +-
>  include/linux/fs.h                         |  2 +-
>  include/linux/fscache.h                    |  1 +
>  include/linux/iocontext.h                  |  2 +-
>  include/linux/irqdomain.h                  |  2 +-
>  include/linux/mlx4/device.h                |  2 +-
>  include/linux/mlx4/qp.h                    |  1 +
>  include/linux/mlx5/driver.h                |  2 +-
>  include/linux/mlx5/qp.h                    |  1 +
>  include/linux/radix-tree-root.h            | 24 ++++++++++++++++++++++++
>  include/linux/radix-tree.h                 |  8 ++------
>  22 files changed, 46 insertions(+), 16 deletions(-)
>  create mode 100644 include/linux/radix-tree-root.h
>
> --
> 2.7.4
>

--O9uFcEIpmYvy18ul
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnac/EACgkQ5GN7iDZy
WKfp7xAAoOGndfBeCCDaUoat2rL4d0CYwVKpSm1S9KaBMPien9InhQ0sQxtSpPvq
gra5Z2N2gnw+wPQhoQSzpzLyRf7Zx97sBMysgYCgoXdnj6p8HooNPwGa0AEG//c/
SiBl32z7SpeG7G2n2+8F5lV8AQ6OggWHWiEc1odpQuM50ODhAdFzuxVubALLd6xl
BeGMSKbs8Vcm7eA/pNjmlzOvZ/w/7ZRBFv6wCFeBPviyBrvvR2oIhqfbs7rmKoUL
C1Tv4VeQwI1sZRJMfbAHZpQigay/qVen8jOnfn+pTQ8XGKQFa94o6eoet8m/eXIj
0MIeTNqTSFo8qGXuh7oSlx/5ePB32sp0HCVqPsKVQKiFji5H8f5zA1LORt7o0AkK
xOGf4xewEmf9C8Pedd3GNuPOXWrjWoaN73TkXfjXevRb4sEBFfwJ3LXta24AT4vl
AJ1cxMmnOmaVrMH0MaLY89MuqsxAHgbSezSG/AO3T8vXNTLo/4EQMNug6h0Mpt6+
iSg0GWddjd0rWInaTXlsIawoq47avrKcAsAYccl2m29ny+kxVR9Kff23sOQhLR9Z
UYDZhle4a4rSByEbpiYQlnLUKEkfrvmUsi65hM2ZYy73FDYkDKUtKH6vjJfs/64/
2bQh5q+VSeHCr1Psv7pLf+eIjtpbMmBoTYx0xZ894gwhRmI7jMw=
=Ge7A
-----END PGP SIGNATURE-----

--O9uFcEIpmYvy18ul--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
