From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 10/12] net/mlx4: replace <linux/radix-tree.h> with
 <linux/radix-tree-root.h>
Date: Mon, 9 Oct 2017 09:10:30 +0300
Message-ID: <20171009061030.GI25829@mtr-leonro.local>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
 <1507479013-5207-11-git-send-email-yamada.masahiro@socionext.com>
 <20171008.100013.2081721941420989813.davem@davemloft.net>
 <CAK7LNAQ1BeSb14poieRU4uMsnsEHPNL2zSNtWi1TGN=YrK_8jA@mail.gmail.com>
 <20171008185529.GG25829@mtr-leonro.local>
 <CAK7LNARAhAaO+YjqXyBbi=-udCu8zzGnLMsoVNdkSXtXPuMKsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="JMMA/5w7oqUUivCa"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Ian Abbott <abbotti-GUHe90Wt2aFaa/9Udqfwiw@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAK7LNARAhAaO+YjqXyBbi=-udCu8zzGnLMsoVNdkSXtXPuMKsA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--JMMA/5w7oqUUivCa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 09, 2017 at 02:56:56PM +0900, Masahiro Yamada wrote:
> 2017-10-09 3:55 GMT+09:00 Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>:
> > On Mon, Oct 09, 2017 at 02:29:15AM +0900, Masahiro Yamada wrote:
> >> 2017-10-09 2:00 GMT+09:00 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>:
> >> > From: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
> >> > Date: Mon,  9 Oct 2017 01:10:11 +0900
> >> >
> >> >> The headers
> >> >>  - include/linux/mlx4/device.h
> >> >>  - drivers/net/ethernet/mellanox/mlx4/mlx4.h
> >> >> require the definition of struct radix_tree_root, but do not need to
> >> >> know anything about other radix tree stuff.
> >> >>
> >> >> Include <linux/radix-tree-root.h> instead of <linux/radix-tree.h> to
> >> >> reduce the header dependency.
> >> >>
> >> >> While we are here, let's add missing <linux/radix-tree.h> where
> >> >> radix tree accessors are used.
> >> >>
> >> >> Signed-off-by: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
> >> >
> >> > Honestly this makes things more complicated.
> >>
> >>
> >> The idea is simple; include necessary headers explicitly.
> >>
> >> Putting everything into one common header
> >> means most of C files are forced to parse unnecessary headers.
> >
> > It is neglected, only first caller will actually parse that header file,
> > other callers will check the #ifndef pragma without need to reparse the
> > whole file.
> >
>
>
> You completely neglected the point of the discussion.
>
> I am trying to not include unnecessary headers at all.
>

I understand it and have no issues with that, just have hard time to justify for
myself any benefit of doing it.

Thanks

>
>
>
> --
> Best Regards
> Masahiro Yamada

--JMMA/5w7oqUUivCa
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnbEtYACgkQ5GN7iDZy
WKek7hAAtR2jEZhW99vK3xLBqRuCN/L1s2fWBKBq7BxlgxYkPJhccAK1Y4+HmXGt
AucaU2HZ7MevkXClN8JoastBj/ziplA9/6pFhzIQn8FFqLt9CxBPRiK2d6AaR6Ij
FFbo479mLUFRn94abMKbcUQK+3SA++UZD5OxDGwjLHp2EYOxbztFjb2XABi3zkka
YeQ4DWiBZSgzZ93FO07U0Syk1/29zRjLBehRXaL3P5MVbzfWVzavd+R4+aBML1ey
ORE7zBNI73qUrwGZIL8HjHPlTWlLY3FbCp1laLh/lMUEOCJM3xwDO7pXqkETXa9D
Ne9mKpYJ19A/6v7q2HQniTzCg/ZJNigtGA0wVOrPwO4CCCQg5Upzkdz6hUPnryA8
0MjzE5V2ZXuFWLtI+GrDPcr0xpm8OtUj8aS1ZOF+m447QrQikG98K7lgjZqE5d43
iS2uYetVFRnx62Cn0elRcEyypZWQteb5kgdGEbntjJZGILlZDKlMBRJmZg+wu9dd
0X49R05+DBY0zDg+w+V+zLTDcUHAg6avq9PR27AhPCJlD6BTw3E7T6QATP+GHc68
pisIEfzwtX8/R4/QN8oY9pnVgDE7Kfhw1UOktZH6V5jBDUAlfMX/jocqTisswbky
QAE7LZF4QmAh7aH2Gpmvuq5gopk9wLNqEjHrerGdLjgucu7Yd/8=
=9Vo3
-----END PGP SIGNATURE-----

--JMMA/5w7oqUUivCa--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
