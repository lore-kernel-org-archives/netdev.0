From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 14/39] i2400m: documentation and instructions for usage
Date: Thu, 27 Nov 2008 11:01:40 +0100
Message-ID: <1227780100.3809.52.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <35dc01f4362676409dd3bf18095ee2ffcef1acce.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mbZm39vcHvHCLM32NYiD"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59743 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbYK0KCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 05:02:18 -0500
In-Reply-To: <35dc01f4362676409dd3bf18095ee2ffcef1acce.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mbZm39vcHvHCLM32NYiD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:

> +$ cp FIRMWAREFILE.sbcf /lib/firmware/i2400m-fw-BUSTYPE-1.3.sbcf
> +
> +     * NOTE: if your firmware came in an .rpm or .deb file, just install
> +       it as normal, with the rpm (rpm -i FIRMWARE.rpm) or dpkg
> +       (dpkg -i FIRMWARE.deb) commands. No further action is needed.
> +     * BUSTYPE will be usb or sdio, depending on the hardware you have.
> +       Each hardware type comes with its own firmware and will not work
> +       with other types.

Can that be put into the firmware tree David Woodhouse maintains?

> +Controlling the device through sysfs
> +
> +   sysfs files to control the device behaviour are located in the
> +   per-device directories /sys/class/net/wmxX*:
> +
> +$ cd /sys/class/net/wmx0
> +$ ls -1 wimax/* i2400m*
> +i2400m_debug
> +i2400m_debug_levels
> +i2400m_reset_cold
> +i2400m_reset_warm
> +i2400m_rx_stats
> +i2400m_suspend
> +i2400m_trace_msg_from_user
> +i2400m_tx_stats
> +i2400m_usb_debug_levels
> +wimax/debug_levels
> +wimax/gnl_family_id
> +wimax/gnl_version

Are any of those actually needed for normal operation, and cannot be in
debugfs instead?

> +RX and TX statistics
> +
> +   This file provides with statistics about the data reception from the
> +   device:
> +
> +$ cat /sys/class/net/wmx0/i2400m_rx_stats
> +45 1 3
> +34 3104 48 480
> +
> +   The numbers reported are
> +     * packets/RX-buffer: total, min, max
> +     * RX-buffers: total RX buffers received, accumulated RX buffer size
> +       in bytes, min size received, max size received
> +
> +   Thus, to find the average buffer size received, divide accumulated
> +   RX-buffer / total RX-buffers.
> +
> +   To clear the statistics back to 0:

Couldn't statistics be in some more generic wimax file rather than per
driver?

johannes

--=-mbZm39vcHvHCLM32NYiD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLnAAAAoJEKVg1VMiehFYm2AQAIM5YKDKI+WLAiNxV9tGWCaX
AnI+QRTytQRxqnGEM57PiH/JioD4OBSG2HNMsx9zU4D3RBu/xeTSCsOtgYyMLOnw
6O4NKVDTCf41uCR5wle7sK9iaJJAtH9qqioFbMEPQRWh0UrHRYMY4nPR/PPyxMeV
Fq4Im8zlY2ZX+Zz5Tu2wmUNpK3f+BUkNDGCj1bBKIg7FjR+bOc+uJAO4c5MWZlsZ
zIiisYC+m+GbjbNWuh/WdKktXoOoJEaBeOym2wszs0ITZylyfzgR5q9B/fl0Zb6p
sEWMqy8ocfeysUkaoSIHbYJY6dAOTuyWbvU5a5vyHHaT4nmKCcZXF09qjwlfyozY
0jqTP7rPJAiofp2drP2iKhgEcCsrNk+1XS7QSyxyg30wyzhtB5yVubJ5aZaDVfYj
AhJiT53P1W21qZS5Cj80tPw9UdZsP6bhZiDe+MOr6wfRA/nSw6Sgx2ayk4EnaVbG
c8CoO1fBvTaIYZeO/A6EdaSTcpEtN3aM1r5PoPvcwrgMhk4qbw6Bj0l3Ynuk2G5s
ekKeDNrLSz9B/8S45R/E5ejksmnCp09xM3brUwLcOhwHs5j8K20LFTTBhFLiqMhu
K/+xDnXHhZFxJQIpi6GCbKaUSqWpMqJJv8SOHElvuLxX4StmZwmyg4ZaCbY2jjkU
TTNqOCa+2Bw7odQ0WmjR
=z4UW
-----END PGP SIGNATURE-----

--=-mbZm39vcHvHCLM32NYiD--

