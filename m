From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4] net/mlx4_core: Use min3 to select number of MSI-X
 vectors
Date: Mon, 15 May 2017 11:12:56 +0300
Message-ID: <20170515081256.GB3616@mtr-leonro.local>
References: <1494569451-2567-1-git-send-email-yuval.shaia@oracle.com>
 <20170514190133.GC28994@yuval-lap>
 <20170515044304.GV3616@mtr-leonro.local>
 <20170515075324.GA3523@yuval-lap>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Sh7h4lnU5nPTsIof"
Cc: <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170515075324.GA3523@yuval-lap>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Sh7h4lnU5nPTsIof
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 15, 2017 at 10:53:24AM +0300, Yuval Shaia wrote:
> On Mon, May 15, 2017 at 07:43:04AM +0300, Leon Romanovsky wrote:
> > On Sun, May 14, 2017 at 10:01:34PM +0300, Yuval Shaia wrote:
> > > On Fri, May 12, 2017 at 09:10:51AM +0300, Yuval Shaia wrote:
> > > > Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > > > ---
> > > > v0 -> v1:
> > > > 	* s/"min_t("/"min_t(int"
> > > > v1 -> v2:
> > > > 	* Use min3 instead of min_t twice
> > > > v2 -> v3:
> > > > 	* Change commit log header message to reflect the changes made in
> > > > 	  v2
> > > > v3 -> v4:
> > > > 	* Cast return value from num_online_cpus to int to avoid
> > > > 	  compilation errors from "sparse"
> > >
> > > Hi Leon,
> > > Got your r-b for v3, can you please review v4?
> >
> > What was the sparse error?
> >
> > num_online_cpus() is declared as "unsigned int", so you don't need to d=
o casting.
> >
> > =E2=9E=9C  linux-rdma git:(master) git grep num_online_cpus include/
> > include/linux/cpumask.h:#define num_online_cpus()       cpumask_weight(=
cpu_online_mask)
> > include/linux/cpumask.h:#define num_online_cpus()       1U
> >
> > =E2=9E=9C  linux-rdma git:(master) git grep cpumask_weight include/
> > include/linux/cpumask.h:static inline unsigned int cpumask_weight(const=
 struct cpumask *srcp)
>
> But num_eqs and reserved_eqs are ints so assuming the error is that i
> asked min3 to compare unsigned int with int.
>
> This casting cannot do harm because anyway the result is stored in int
> variable.

Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--Sh7h4lnU5nPTsIof
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkZYwgACgkQ5GN7iDZy
WKeOdQ/+Ksl2k+JYiz8zMZqvJEjIeb41yAV8S+to3mTl9B3noCY3ACMrt+0p6fuI
RLyTtcK7u9K42mqPgONRAl2UDLtmyhEhdtq1EUyGV3dEA9qXW/esI4C2JlGAjKSM
VhYVeIV8OYIK75NORQls2uRXfXHnPYVHBTJFoRqXUYQcQSDYSJhc/t2Y4WutNgIk
kGBFyMHIm0E+Ybs2beGbLlLLxE6Vnp8SobiFcdsLpdTF9+tynemkBac6E46z5ZFA
hqw0xGjQHevl8kdmD2FjtJ0WazokR5wkhigErtztH910BmvXOfywZOXpTbqGG3UR
ze7/jLnq2g06TD8tVjYHBVVDD4xXDmEeD9RkpsvC2KN8pXKXVQ7edxjBrQNbvZGA
noHYrCd/zYBWoeasCYeciA1xpth/Wb89RHWWEeJf1RuyaDGHHlcT9R0bjtE7kBBq
I/YYWb4c4dInNg02TwSt2/rSl8DOqXsC9dKtsaANNINdKQrHVOctjzaNt/c+Yu4+
+O8WaBm7CJpLF2H7N7yPS+9p+60uSVHxsfHqF3HtQ4gneIOIQ6lfuOh/Q59ishJT
Lc5hV/rIXTScyLdAMRW3kPzh+20uyfN+Ydt/0J4wwf77kaSH3iloBzqnLHl2h23d
7RMaQ2BIWa0Rtm9UisCMlb4KBKYG7IDQWZpks6h3u6byqZVt5jM=
=wWKA
-----END PGP SIGNATURE-----

--Sh7h4lnU5nPTsIof--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
