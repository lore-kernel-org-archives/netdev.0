From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH net 1/2] net: cadence: macb: Disable USRIO register on
 some platforms
Date: Mon, 7 Dec 2015 13:32:15 -0600
Message-ID: <20151207193215.GI29051@jcartwri.amer.corp.natinst.com>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
 <1449485914-12883-2-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="smOfPzt+Qjm5bNGJ"
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Harini Katakam <harini.katakam@xilinx.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449485914-12883-2-git-send-email-narmstrong@baylibre.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--smOfPzt+Qjm5bNGJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Dec 07, 2015 at 11:58:33AM +0100, Neil Armstrong wrote:
> On some platforms, the macb integration does not use the USRIO
> register to configure the (R)MII port and clocks.
> When the register is not implemented and the MACB error signal
> is connected to the bus error, reading or writing to the USRIO
> register can trigger some Imprecise External Aborts on ARM platforms.
> ---

Does this make sense to even be a separate bool device tree property?

This sort of configuration is typically done by:
   1. Creating a new 'caps' bit; relevant codepaths check that bit
   2. Creating a new "compatible" string for your platform's macb
      instance
   3. Creating a new 'struct macb_config' instance for your platform,
      setting any relevant caps bits when it is selected.

  Josh

--smOfPzt+Qjm5bNGJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWZd68AAoJEKp7ZBKwQFAr1W4H/jZAVm4x25e3YDa0YoxFhdug
Z8AwjPSJUG4h7ScuMHdSffrcxcIX+nBvN7ilDGXVuxUePwZYS6zVYBvLLH+rtVRC
IyixXM+xgX+bxCvDuM40Yl0CbXY9Y44sqxPFhHdthEyDfSMElyLjuc3Btj+1FAce
QlhOznwSs4c+1wXaaLlolQgpEH9g4zly9ghmRenCFi5tPWO8p+h514pQLO3/wrq2
rZBsyhYYgCvExhMEmd0iDfsG3t8aVEZgfJBSAaR6KdaujXYUsR4q8UKSpfgSNMOP
cjajvQrrIMx4Dp/StIIjFTRl6ipFfegZm7OPSAiImaq4OLBi7fcEXs+Vz4iljmU=
=rV7l
-----END PGP SIGNATURE-----

--smOfPzt+Qjm5bNGJ--
