From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Mon, 15 May 2017 10:18:49 +0300
Message-ID: <20170515071849.GZ3616@mtr-leonro.local>
References: <20170510072627.12060-1-hch@lst.de>
 <1494514662.2489.1.camel@sandisk.com>
 <20170514055848.GA23149@lst.de>
 <20170514.115116.499149210596634881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="YHHegWJYV76VGRm9"
Cc: hch-jcswGhMUV9g@public.gmane.org, Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170514.115116.499149210596634881.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--YHHegWJYV76VGRm9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, May 14, 2017 at 11:51:16AM -0400, David Miller wrote:
> From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
> Date: Sun, 14 May 2017 07:58:48 +0200
>
> > this patch has not been superceeded by anything, can you explain why
> > it has been marked as such in patchworks?
>
> I think you're being overbearing by requiring this to be marked BROKEN
> and I would like you to explore other ways with the authors to fix
> whatever perceived problems you think SMC has.

Hi Dave,

Christoph proposed very clear way to remove BROKEN tag, by providing
secure environment by default to all users.

All ULPs in RDMA and lustre in staging [1] are working in secure mode
by default and I don't understand why SMC-R should be different.

=46rom my experience such "BROKEN" tag will help for authors to get proper
priority from their managers to fix it in a first place, before they are
moved to anything else.

>
> You claim that this is somehow "urgent" is false.  You can ask
> distributions to disable SMC or whatever in the short term if it
> reallly, truly, bothers you.

It is not distributions only. For example, RDMA stack is released by
different providers. Mellanox OFED [2] is one of them and it is based on
upstream kernel.

Thanks

[1] e0ccf5d085ab ("staging: lustre: ko2iblnd: Adapt to the removal of ib_ge=
t_dma_mr()")
[2] http://www.mellanox.com/page/products_dyn?product_family=3D26&mtag=3Dli=
nux_sw_drivers

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--YHHegWJYV76VGRm9
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkZVlkACgkQ5GN7iDZy
WKcb+A//SPoz91215P1vqdulAXFNAZWeqz96b8AIvnoQbybS0Pu/O8uoSOhRI1P1
lU21Ajtzc5vbLrzs7lB0qHdWMyZAZzx3oabV4aPvolohyl5/ZYiy2nhInxxRpaGC
any/cje3sIHvlT/UswWUIg/cvwh8+VcRWpZSDTIYH3h56hnIfZ46vCBd7QzNKEVP
phCll/UinofyoIc2630Yyg9O3VjE3yzHMQsmhJo1/7YJeqb8xgnzDBNa4XO0p5Dg
HXO2XBEOEfjVqT4F30mdyLK7QvDcKzmr4D+fbTfXZ2jd+CQPpg+SkxsLk3dNGvb3
m73NPwIU2lEiBPup37PUwRMaeEL3zOaNdCTxlIwPxim97+4YrO5MFHzy0oVrDPqr
BNteWZCMYJ9d+T/dN9YIilCxUamLWDGXoD5MUqzeXXBCF72vEBhC5CgarQ+XQd7l
+JAwyYeCsUUNRU+9Lbbx6E73nnMfybkr9jZrfysb0V2lPbww4kTi6qLWNHLceuRR
4wRDR2djztzlhcFNUOT+/FlOpZ32yo2Uw7it+1cu+Af723xB24zHrx37dU+gAOPd
CLrAfIzjldzGlb82arsVRdXwGXAiVns2znvT+XHsZyyhQywKObATwEXKL/Y2x8P+
q37ImZMvM4n7M1jPY0kaivKh01o65MZJQdHIZWWqHSLkfDCpYwk=
=cKQ1
-----END PGP SIGNATURE-----

--YHHegWJYV76VGRm9--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
