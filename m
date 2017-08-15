From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH 1/2] mlx4: remove unnecessary pci_set_drvdata()
Date: Tue, 15 Aug 2017 10:13:36 +0300
Message-ID: <20170815071336.GL24282@mtr-leonro.local>
References: <1502778786-14738-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="vkJ987n7uXEPtlXE"
Cc: saeedm@mellanox.com, matanb@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, yuval.shaia@oracle.com
To: Zhu Yanjun <yanjun.zhu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0077.outbound.protection.outlook.com ([104.47.2.77]:32680
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753077AbdHOHNr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 03:13:47 -0400
Content-Disposition: inline
In-Reply-To: <1502778786-14738-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vkJ987n7uXEPtlXE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 15, 2017 at 02:33:05AM -0400, Zhu Yanjun wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not necessary to manually clear the
> device driver data to NULL.
>

It makes sense and I'm pretty sure that you are right, but I'm failing
to find the function in device core which sets it to NULL. Can you help
me and present the actual call stack to that code place?

Thanks,

--vkJ987n7uXEPtlXE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmSnx8ACgkQ5GN7iDZy
WKfmXA/+P3uZidyL/R9taLe6jflgXY4Wdo2QOQL7fgq7C7jfUMo7p5138WiH92nb
r+TGdqL1u2W8XmSk67py17T7GPAj/ZzMfeLypFLvWoAfROdzD9OE/UZBMCfqvmQ3
8wYPNQf0FAjRfSRZRH4oaDwZzAF2BJiuJTT4pFLfuuFX34i4kSPVXtSBadhesOzW
cB+6qZsFmW17YHPW9Sg+GQvRQ/FXEL2i4ZmkzpwOcnYa9GujtQP7MjHCqjrTVrvl
McdmrRFPN0WPJcGAM/iTcSysTUj9dux+jZhZLbH0U9RuSX1awh6RYqjEQc5oKtJA
eSin6YmrvmtHUaktAlRyEzKWxOoFaak6L9nMfn2Iqb1RwtRz7jDxhlsuH/wdrF1S
a0YZDWPXteU541s/Z1HsJ9af8f1mcY/rHypirCbYdSnFJ/NLI8TTwY2UBZhctEfP
Lns1yaEo+wq7fc8GorPwoXF80bkNAkxfkeVJhGobgaOCnoR2e7hYhKxRXLWYBLiA
TSZb73dIK4OdMT7DNpCUl4S46JQs3Vixs/TFyVMaAA7oozhSbN/CMnaH/GSS71Dx
aoIz55srr74jpl3f72XtQl2Na9+v14xULOXIV2OcxUI9abWMZb5xgwLrsau9ZZTF
r2C1JLjv5BIy2LnMApaXf9FTtIZHoi+nr3m2R6Br7P5w1w4/g2Y=
=l4vv
-----END PGP SIGNATURE-----

--vkJ987n7uXEPtlXE--
