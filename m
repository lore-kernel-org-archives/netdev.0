From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH iproute2 V3 2/4] rdma: Add dev object
Date: Tue, 4 Jul 2017 12:04:41 +0300
Message-ID: <20170704090441.GF1528@mtr-leonro.local>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170704075541.12544-3-leon@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="6WlEvdN9Dv0WHSBl"
Cc: Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0076.outbound.protection.outlook.com ([104.47.0.76]:65440
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752030AbdGDJEt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Jul 2017 05:04:49 -0400
Content-Disposition: inline
In-Reply-To: <20170704075541.12544-3-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6WlEvdN9Dv0WHSBl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jul 04, 2017 at 10:55:39AM +0300, Leon Romanovsky wrote:
> From: Leon Romanovsky <leonro@mellanox.com>
>
> Device (dev) object represents struct ib_device to the user space.
>
> Device properties:
>  * Device capabilities
>  * FW version to the device output
>  * node_guid and sys_image_guid
>  * node_type
>
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> ---

<...>

> +}
> +
> +static void dev_print_node_type(struct nlattr **tb)
> +{
> +	uint8_t node_type;
> +	/*
> +	 * FIXME: move to index exported by the kernel
> +	 */
> +	static const char *str[] = {
> +		"UNKNOWN",
> +		"SWITCH",
> +		"ROUTER",
> +		"RNIC",
> +		"USNIC",
> +		"USNIC_UDP",
> +	};

There is a bug here, i forgot to add "CA" to the list of node_types
(before SWITCH). Thanks to Or Gerlitz who spotted it.

Thanks

--6WlEvdN9Dv0WHSBl
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllbWikACgkQ5GN7iDZy
WKfUsxAAh+XO+EhsCg6Yhwi3Nja1eBC6vF+Bdt3CAxNpLuX7su/2PfkWQ2RfuaRs
b7Jbt5FtgQEe9+QEl9b+93jnXM7sKiqjD4PYS2QO4y1MA4qf4+spo5F1Y6DI2KG6
uixSsfpx0b6UX6GhPcYc9JDGt8ggAhfBlFefN144CrxTtolxKEBve02lJ3bhETop
iSfUDukHJEHP3VqPZHRZp/7bck1+UdkY5LvTH0r4gS+cjbl7pOw564ihRe4Av1we
Y8d//7QcHCwzxjY/PepdXIApxtoahRCP/gakIIwM87CDuq47q4bdCe+RZLc9zn6Z
5grpD09Lan8l9i/pYxROwJujKVyKMC2G1eHjpEdooevXjmTn8LVjf5+6UoiduC8v
bnNjJbDmuORDSiJeF7nXXAzsvxv9yTXs7F0EFSJqFNlK5Ol3VnDb+o+X2dd6vRn5
Aai6JPWWQox47vY+dO/e4wyzFOVVjXbtxJuw3Y3LpKAtfpj3H6rZ52v2mBVsV8+7
ZeGhd6mbj5P15Qqbd4EhVqdWQ1zgAg8D4pVI3g003E3Xtw9m65J6t4iF+9AcQ9J5
H+j6fQll/0NhqQIRJyU3/ccnKa+RiBFROckbe6rgXMSgaJOuuZXEL4uvSCQD90DN
KeUB29ojxrXFhejnJNzW9k9Cgremy+vXOnzw3eeaSQ7khw0OdqA=
=PpzX
-----END PGP SIGNATURE-----

--6WlEvdN9Dv0WHSBl--
