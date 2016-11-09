From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for-next 09/11] IB/hns: Change qpn allocation to
 round-robin mode.
Date: Wed, 9 Nov 2016 09:24:24 +0200
Message-ID: <20161109072424.GI27883@leon.nu>
References: <20161104163633.141880-1-salil.mehta@huawei.com>
 <20161104163633.141880-10-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="kH8JNVvasRCCW1Oz"
Cc: dledford@redhat.com, xavier.huwei@huawei.com, oulijun@huawei.com,
        mehta.salil.lnk@gmail.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161104163633.141880-10-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--kH8JNVvasRCCW1Oz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Nov 04, 2016 at 04:36:31PM +0000, Salil Mehta wrote:
> From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
>
> When using CM to establish connections, qp number that was freed
> just now will be rejected by ib core. To fix these problem, We
> change qpn allocation to round-robin mode. We added the round-robin
> mode for allocating resources using bitmap. We use round-robin mode
> for qp number and non round-robing mode for other resources like
> cq number, pd number etc.
>
> Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
> Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>

Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--kH8JNVvasRCCW1Oz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYIs8oAAoJEORje4g2clinMX0QAIp8H3SvyBOCRCy703fJxfcR
/aZWao7glyMs0V2/jALetJIMjqiKzFcVy4xqSjFROU9qJMubgz4ZG06h4UTTT6ad
Qb+miVJ4FiwZ0ebuifG5QT40S2A81gN09OGVbYPbYVFO2eiVceXynARHM4HbYUHq
522PB3u+NsBiVwfBT8hDkME8hX/6KiKYKD5GtNRDUAOQmsi3aGPULyjsyABG+RJf
pfxeAdku5sPieSIrcqRBuneC2ciPylHE7GV0b1lR8cJXfw45Ng5H2HFa0wwRipX6
PNYYUFKmBaRcHqbCzLJ8kVWTLfSwRj7qP/ub3bl/ayHbmOt7xtVbZv6sAXu8NI4t
J8vIYxl3G6nU2z7VinrqBaZhqTQlJWDBK0m6q2hdU7THE3nK1FVMJlyYehP5muR3
emzaS7ahIWCEpkiGV4I3EqOZmz+r2n9VL85mLM9uwkGLs79h/alLAEiMZcOkPuZ8
scmCnyzonm53lXuUAwIs7OX5UXQhfi/ZhgxF0RwakjH4taH1arLh/ncL1Bdq6E/H
3liFSSZ1Zl8+cIFQ+waxR26khsVZYS6U0ewQSpaPkS1Ma9oDXpkyKmB1jgX+Ki0/
24zot00sLTtUEH1vdCnPLW03ZcY5YBYf8eGRltS0s4l65iyW6uMnSt4lylxiJWTs
eugCv+6UET1dUFDIOawW
=VhTx
-----END PGP SIGNATURE-----

--kH8JNVvasRCCW1Oz--
