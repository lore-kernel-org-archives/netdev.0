From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH v4 2/2] net: hisilicon: add hix5hd2 mac driver
Date: Fri, 6 Jun 2014 10:19:18 +0200
Message-ID: <20140606081917.GD31915@ulmo>
References: <1401774577-16683-1-git-send-email-zhangfei.gao@linaro.org>
 <1401774577-16683-3-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pZs/OQEoSSbxGlYw"
Cc: davem@davemloft.net, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	haifeng.yan@linaro.org, jchxue@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Zhangfei Gao <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:64082 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbaFFIWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 04:22:08 -0400
Content-Disposition: inline
In-Reply-To: <1401774577-16683-3-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--pZs/OQEoSSbxGlYw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 03, 2014 at 01:49:37PM +0800, Zhangfei Gao wrote:
[...]
> diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
> new file mode 100644
> index 0000000..e942173
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/Kconfig
> @@ -0,0 +1,27 @@
> +#
> +# HISILICON device configuration
> +#
> +
> +config NET_VENDOR_HISILICON
> +	bool "Hisilicon devices"
> +	default y

Can this default please be dropped? It's annoying because it will cause
this driver to be built for *every* ARM kernel by default, whether or
not that hardware is available on a given board.

Thierry

--pZs/OQEoSSbxGlYw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTkXmFAAoJEN0jrNd/PrOh+u4P/3nKNgvzRNblSr+tfJtPa2/Z
ooJZFI9TjBbLasddaHzYLKuX+otUDw0xKIjNTXeu43urpvj7SilJ2pR7aYf/y4Lt
hdpj1vfamZoR6Jwpr1PTMOUXE1gfAD+Z2Ui4JeCKmm47zBejlvNQrvYRI4DZ+H8j
E/znaOIMwbEBLxbHtcf3OdEpxWoTCs6YgjkQonSTDXM06J73QATyRODpfoz8Hg+7
zpj8fsr57NwDSFUbLADAoOxL53Z/6HNg4GA/WkHg6SAgVEQE/5YODZ/NzjSEC1Bm
5I4q/cd/IhdlLvRKfk2zhc1uoc0QImVifX3ih1iEtCIK7loA4+o8GCHxABzvsmbB
VC8cn2do5cUezwsmaMwL12VxnDNUSyywhTiIuc/iJ+E5K2dB7+W1J/agAIcNUel8
/FP3k2W8dU9KloIyrEYm5R44S8mbtpYnzUy94unadzODF+u8p8bjoh4KUZksYCci
8fcbrr0J77WhKlOZAJtZ/VR9RcRpZkf2bYF43d8BW8d/0gRUoVddkvPcH93N70Ea
h8spQO0y5sziFOrko6YyjisxsOjQ3nwUGxmztS+2jB8ChZuSXhfDlgGqQMyD7KVA
tUGkB6lQtV1PMwTcv+ERWGKgOX5pEQkmsSq4nefO78sfIZnagccO8ESnxGGraKLc
h41/eJeQ38gVWwkphkyO
=sjrC
-----END PGP SIGNATURE-----

--pZs/OQEoSSbxGlYw--
