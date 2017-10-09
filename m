From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH 00/12] radix-tree: split out struct radix_tree_root out
 to <linux/radix-tree-root.h>
Date: Mon, 9 Oct 2017 09:05:40 +0300
Message-ID: <20171009060539.GH25829@mtr-leonro.local>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
 <20171008185233.GF25829@mtr-leonro.local>
 <CAK7LNAQrtikienLa+HXtnXmwCrTEQSnqU0Ne-BrFvKpaFMUxqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="RkLO0ZVuuT1d19pw"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ian Abbott <abbotti@mev.co.uk>, Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-cachefs@redhat.com, linux-sh@vger.kernel.org,
        Rodrigo Vivi <rodrigo.vivi@intel.com>,
        dri-devel <dri-devel@lists.freedesktop.org>,
        David Airlie <airlied@linux.ie>, linux-rdma@vger.kernel.org,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Tariq Toukan <tariqt@mellanox.com>,
        Rich Felker <dalias@libc.org>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        intel-gfx@lists.freedesktop.org,
        Yishai Hadas <yishaih@mellanox.com>,
        Joonas L
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAK7LNAQrtikienLa+HXtnXmwCrTEQSnqU0Ne-BrFvKpaFMUxqQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--RkLO0ZVuuT1d19pw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 09, 2017 at 02:58:58PM +0900, Masahiro Yamada wrote:
> 2017-10-09 3:52 GMT+09:00 Leon Romanovsky <leonro@mellanox.com>:
> > On Mon, Oct 09, 2017 at 01:10:01AM +0900, Masahiro Yamada wrote:
> >
> > <...>
> >>
> >> By splitting out the radix_tree_root definition,
> >> we can reduce the header file dependency.
> >>
> >> Reducing the header dependency will help for speeding the kernel
> >> build, suppressing unnecessary recompile of objects during
> >> git-bisect'ing, etc.
> >
> > If we judge by the diffstat of this series, there won't be any
> > visible change in anything mentioned above.
>
>
> Of course, judging by the diffstat is wrong.
>

I'm more than happy to be wrong and you for sure can help me.
Can you provide any quantitative support of your claims?

Thanks

>
>
> --
> Best Regards
> Masahiro Yamada
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--RkLO0ZVuuT1d19pw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnbEbMACgkQ5GN7iDZy
WKcD5RAAiP8e5GL5cKh8/eWelpl1NbeMYeER6Ow0DskGRWmbfgRbWqSLdfzfP1AF
F2bLU3g+amKgziXgdSW55Kudh2Ul+YZmxSyLtbO0C1pKpIu4ZxmwP6ALfgtp2V5A
fcCyoKJZIukkLf7UwQ5/2fP+JQJp8k4SFvsJFSb2gEdXdTp209nm0Vh66i1lpBMh
AzYAAJL38NCF4NnXCEoQFn7lY03iXiHlf8GJnDnI5Jh/b8fh4Sj5zv0J+hzVVETN
+DRCaxkxl9F5DiR+U1BZxMRIxnDaIhWVC5lXmDgY1f3hR5A8LIVQXq23K0iu58BV
qQ5+pEII9hyu7iSNnesJ8B29DsSA8jex7LKnJ8JPABFEkrUf0WT6lMS9nf0jlRRx
mwcrKRIMCPKu5FS3YNEdWTZQrIx9B4p7rn/61N/JEcmfdFweQKRHwaGS4ADycd28
+JRiVq/HXiDFlIR1UYzKCimHeNx8dcjvq8soqPKfJzI+Sc3D0mxPk6c5R5WMARh8
E1+HiLKz0L1L+2ppNwokk4k8zXKdKFjWpzEhAzCABBVrKWBCNOcUGwKVwmavD04n
XJhdnRSiixO1blnYy8A33xMt+dh51XfrZvzhmHTnX72OCXjAtPKMTWU1BkJoLlXy
ZYyLqOLtyajrXg+6BPtlYOQ32erqYrqlQ1Un7fMBexSqS5drZ/4=
=Oft4
-----END PGP SIGNATURE-----

--RkLO0ZVuuT1d19pw--
