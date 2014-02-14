From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v2] can: xilinx CAN controller support.
Date: Fri, 14 Feb 2014 09:55:26 +0100
Message-ID: <52FDD9FE.8040908@monstr.eu>
References: <\> <0dc128ac-e5cd-47bd-9ab1-3a545c3e2043@CO9EHSMHS012.ehs.local> <52FD1B16.6020600@pengutronix.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="cafLha3RjWhHeNvLUaACRjLplUrb21vHE"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:63913 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666AbaBNI4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 03:56:04 -0500
Received: by mail-ee0-f49.google.com with SMTP id d17so5481677eek.22
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 00:56:02 -0800 (PST)
In-Reply-To: <52FD1B16.6020600@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cafLha3RjWhHeNvLUaACRjLplUrb21vHE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Marc,

>> +	int waiting_ech_skb_num;
>> +	int xcan_echo_skb_max_tx;
>> +	int xcan_echo_skb_max_rx;
>> +	struct napi_struct napi;
>> +	spinlock_t ech_skb_lock;
>> +	u32 (*read_reg)(const struct xcan_priv *priv, int reg);
>> +	void (*write_reg)(const struct xcan_priv *priv, int reg, u32 val);
>=20
> Please remove read_reg, write_reg, as long as there isn't any BE suppor=
t
> in the driver, call them directly.

That's not entirely truth. If you look at Microblaze then you will see
that Microblaze can be BE and LE.
There is just missing endian detection which we will add to the next vers=
ion.

But because MB io helper functions are broken for a while you should be
able to use this driver on both endianess.

btw: I would prefer to use ioread32 and ioread32be instead of readl.
Is it OK for you?

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--cafLha3RjWhHeNvLUaACRjLplUrb21vHE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlL92f4ACgkQykllyylKDCFSbwCaAmXxeKjT7a64na83jdx4Dwv4
t+gAoImSI59tzdRYMwx5PuSO2r2WBIdc
=rhln
-----END PGP SIGNATURE-----

--cafLha3RjWhHeNvLUaACRjLplUrb21vHE--
