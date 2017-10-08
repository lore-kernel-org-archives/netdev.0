From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 10/12] net/mlx4: replace <linux/radix-tree.h> with
 <linux/radix-tree-root.h>
Date: Sun, 8 Oct 2017 21:55:29 +0300
Message-ID: <20171008185529.GG25829@mtr-leonro.local>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
 <1507479013-5207-11-git-send-email-yamada.masahiro@socionext.com>
 <20171008.100013.2081721941420989813.davem@davemloft.net>
 <CAK7LNAQ1BeSb14poieRU4uMsnsEHPNL2zSNtWi1TGN=YrK_8jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Kra4tWuoVJHqwr45"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>, abbotti@mev.co.uk,
        Ingo Molnar <mingo@kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-rdma@vger.kernel.org, yishaih@mellanox.com,
        tariqt@mellanox.com, netdev@vger.kernel.org
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAK7LNAQ1BeSb14poieRU4uMsnsEHPNL2zSNtWi1TGN=YrK_8jA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Kra4tWuoVJHqwr45
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 09, 2017 at 02:29:15AM +0900, Masahiro Yamada wrote:
> 2017-10-09 2:00 GMT+09:00 David Miller <davem@davemloft.net>:
> > From: Masahiro Yamada <yamada.masahiro@socionext.com>
> > Date: Mon,  9 Oct 2017 01:10:11 +0900
> >
> >> The headers
> >>  - include/linux/mlx4/device.h
> >>  - drivers/net/ethernet/mellanox/mlx4/mlx4.h
> >> require the definition of struct radix_tree_root, but do not need to
> >> know anything about other radix tree stuff.
> >>
> >> Include <linux/radix-tree-root.h> instead of <linux/radix-tree.h> to
> >> reduce the header dependency.
> >>
> >> While we are here, let's add missing <linux/radix-tree.h> where
> >> radix tree accessors are used.
> >>
> >> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
> >
> > Honestly this makes things more complicated.
>
>
> The idea is simple; include necessary headers explicitly.
>
> Putting everything into one common header
> means most of C files are forced to parse unnecessary headers.

It is neglected, only first caller will actually parse that header file,
other callers will check the #ifndef pragma without need to reparse the
whole file.

>
>
>
> > The driver was trying to consolidate all of the header needs
> > by including them all in one place, the main driver header.
> >
> > Now you're including headers in several different files.
> >
> > I really don't like the results of this change and would
> > ask you to reconsider.
> >
> > Just add both radix-tree-root.h _and_ radix-tree.h to mlx4.h
> > and leave the rest of the driver alone.
>
>
> If you do not like this, you can just throw it away.
>
> <linux/radix-tree.h> includes <linux/radix-tree-root.h>.
> You do not need to include both.
>
>
>
>
> --
> Best Regards
> Masahiro Yamada
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--Kra4tWuoVJHqwr45
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnadKEACgkQ5GN7iDZy
WKcU/w/+IV/xfGH1SRd5FqoN7noTc/kYlBAXPyI7c3io/tfZDeLUd114YTKMbowW
IrqxTgOxWgD8bmW+3w5kYjneDz8n7olzRBTit3HoRcqK1HgfpTAKFb7RhJBSXbRP
Jqi7rFX2iYkO4mwu9PBR6yEbrRz4Cc9cvLrO0tB4HfBawn6oZKP1GaWVfbSUvGMg
2XV7nhvXsvWHAUnVYqvEoR7olehLjtJi8W7pKmI+CzbjLkiBjdQWapHJsA/3ED5Y
EcCN6IqGTSryYzVIwFlmZ/cHtLWO9OazrpkXAPnHWtTrPJDyU70Q3QtI+Pq7kf/B
aXhdJY4PAjQaWujTL8qx597sJ5edmOAFxDlVLgMx+MrXREQD5+tCt8ieGLNANG68
Iw9du/Y0wvg+sDSLZzeUNVQmxyfMXvlU6KPREnwui+Bd0uXzzgMhjsRBWonJvaZj
oS8djFuoIoY29zO+eAT10chOxNNzv2DXJmPPJgu46eUmoe/1BcJviCl5qT3BIjeP
ZH1mAq0Umn83y3b72BbxiIe6GcQu+7+4Y2MkSfaZC8qqwBUg7FuoNxJBEOGVr32y
+wMqvOQgWmVphrnBoGa7+mLIUbAeLHoP69+nNuLElpPOuKEJEEvZSMO9t3iaLHeR
Yp3ZYg4FU0DZT7VobjPNjdc3m5Fi2vUYHwAzjvlkhWLBPB8fqnY=
=bN5m
-----END PGP SIGNATURE-----

--Kra4tWuoVJHqwr45--
