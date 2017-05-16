From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net v1] net/smc: Add warning about remote memory exposure
Date: Tue, 16 May 2017 10:03:30 +0300
Message-ID: <20170516070330.GP3616@mtr-leonro.local>
References: <20170516065138.24789-1-leon@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="pcjGMRtmGLNVN1Bo"
Cc: ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170516065138.24789-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--pcjGMRtmGLNVN1Bo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

+ linux-rdma ML.

On Tue, May 16, 2017 at 09:51:38AM +0300, Leon Romanovsky wrote:
> From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
>
> The driver explicitly bypasses APIs to register all memory once a
> connection is made, and thus allows remote access to memory.
>
> Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
> Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
> Dave,
> Can you please forward this patch to stable?
> Thanks
> ---
>  Changes from v0:
>   * Remove BROKEN Kconfig option as a followup of this discussion
>     https://patchwork.ozlabs.org/patch/760454/
>   * Refine commit message
> ---
>  net/smc/Kconfig | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/net/smc/Kconfig b/net/smc/Kconfig
> index c717ef0896aa..33954852f3f8 100644
> --- a/net/smc/Kconfig
> +++ b/net/smc/Kconfig
> @@ -8,6 +8,10 @@ config SMC
>  	  The Linux implementation of the SMC-R solution is designed as
>  	  a separate socket family SMC.
>
> +	  Warning: SMC will expose all memory for remote reads and writes
> +	  once a connection is established.  Don't enable this option except
> +	  for tightly controlled lab environment.
> +
>  	  Select this option if you want to run SMC socket applications
>
>  config SMC_DIAG
> --
> 2.12.2
>

--pcjGMRtmGLNVN1Bo
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkapEIACgkQ5GN7iDZy
WKdBBA/8DXby2A62qie2ViXY8R5uxDkVinaqb1qf7NBfraDHxXnFclfdhW5IqGDh
qey7j94myaoigIWsH7vquq/EUW2v7uvM/8yYuFyDwosNliffRWdimjK5FZcHOTcH
QCLweYqBhuQHhrYLkEMU7awu6w5v5u5e1Oi9YOSKO6Wo90ppp61cibkckyExgzTg
9BXkzTSpVccMsNNIBD34Xape/jWspa9xgcmgBspDlI3Nh477yMV1N89HomjtChK+
i9ei5VoOp55qMoJ0xVutZQR0Cs7TnYfhjf7fGZ3VcirRjLnYJMCpe7uQTMezpybS
hZb1SjYAGz6TLXvuL/ekOH55vweJ7aHqG1rEbawDqKXf7/UOKbz9kOxsUBWsAtGA
jQYx+8MN2TBn//P3IJ4ks8s0fX5hrulRu/JKoKZ4b8si3xvfGCmesicjlSLk4XiG
uk0mX8UYOeMsVy2i7JMjCwu0tyK3owkbKm9d0LRbrmLIYco4O/2OIB0bd6/gRCWk
NURn5I7eVnrgmfA7AtWNrwyRwMXLCyHhzCIecMAZDgZcRBuo/IJXF5VCSW7B8gs4
OM4SpSkYGQwDDxB4zK4Go0pgi0vlB2Rx/nneFgfmZlgxp3ekDSpRDNF6CPxWEAEF
6X0fyXVzJGSzuZqu6viB6r0rHSi+A7K4wmiUz1ObY/s8eZv4eCM=
=UzGt
-----END PGP SIGNATURE-----

--pcjGMRtmGLNVN1Bo--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
