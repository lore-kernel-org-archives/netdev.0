From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] net/mlx5: clean function declarations in eswitch.c up
Date: Sun, 18 Sep 2016 13:56:02 +0300
Message-ID: <20160918105602.GC2923@leon.nu>
References: <1474188262-9929-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ZwgA9U+XZDXt4+m+"
Cc: matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        arnd-r2nGTMty4D4@public.gmane.org, xie.baoyou-Th6q7B73Y6EnDS1+zs4M5A@public.gmane.org
To: Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1474188262-9929-1-git-send-email-baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--ZwgA9U+XZDXt4+m+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 18, 2016 at 04:44:22PM +0800, Baoyou Xie wrote:
> We get 2 warnings when building kernel with W=1:
> drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c:463:5: warning: no previous prototype for 'esw_offloads_init' [-Wmissing-prototypes]
> drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c:521:6: warning: no previous prototype for 'esw_offloads_cleanup' [-Wmissing-prototypes]
>
> In fact, both functions are declared in
> drivers/net/ethernet/mellanox/mlx5/core/eswitch.c,but should be
> declared in a header file, thus can be recognized in other file.
>
> So this patch moves the declarations into
> drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
>
> Signed-off-by: Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

Thanks,
Acked-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--ZwgA9U+XZDXt4+m+
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX3nLCAAoJEORje4g2clinmxoQAJPCoXjWe6KatGnowzBeCSGz
Lhq9vUM4P+il6YVrkyBgs8HazzJ5I6f+XkKPdiLfXCSz8yOvix0To35hQYMVjFV+
Q7bkWJ5j0R+vJRmE91TFe4YNNQOKLiIie0xU0VMv6uj7xC/4NHjqBn2nrxJnN9EH
3URE797Bt7TNjwLRftOaiuYVeWGTiRfnO2thRP5OyqCwhdrnohea5I1pIJkclEqM
RBTmlSWSqzBZo/PtCDQLoBIhNyiVouP617NP8pg2XcrvzF2bQmrbpTzcHyOqKWj9
dYmziiOs7W232d1kUAAuA8LxrpKGfSLGJRXBooYqd2Pz68piGXs8ueQPeaJE/g3v
sFvz3f/A2ITBT9vAgBHGpD1xTP+3J5nYUZSE78WTokD7rEUVMVacjMwMVZnOQFj6
ds3qdkraM0NtPh6IBrHA2dkTuYBxkn/3WBBkC0HWTXkuG1EbPRW86wg29pPSg35E
QUhms2eE9NDyBQIJJ86VI0HAEWByTZjtB2Ap7iuouP8IaGLfPmRhFuAAsuLNZUYw
cD9nvulsuOtIlR7VpS6g7C2Os12kNh39jGvnbK4qB5Ivf6SacTZ4dimAEI/V9O8y
GwBc98jV4v0KpJYiLxQQZnGdGRjRHRQHyR7Q/HER/40y+UvvL4tqE+3X1FCUZyDk
CGVaaw9rKCVstgHwMm4N
=CBK7
-----END PGP SIGNATURE-----

--ZwgA9U+XZDXt4+m+--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
