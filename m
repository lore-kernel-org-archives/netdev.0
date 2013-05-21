From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [PATCH] MIPS: OCTEON: Rename Kconfig
 CAVIUM_OCTEON_REFERENCE_BOARD to CAVIUM_OCTEON_SOC
Date: Wed, 22 May 2013 01:04:57 +0300
Message-ID: <20130521220457.GF31836@blackmetal.musicnaut.iki.fi>
References: <1369088378-13957-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        David Daney <david.daney@cavium.com>,
        linux-ide@vger.kernel.org, linux-edac@vger.kernel.org,
        linux-i2c@vger.kernel.org, netdev@vger.kernel.org,
        spi-devel-general@lists.sourceforge.net,
        devel@driverdev.osuosl.org, linux-usb@vger.kernel.org
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1369088378-13957-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Hi,

What about OCTEON_WDT, should it be changed too:

        tristate "Cavium OCTEON SOC family Watchdog Timer"
        depends on CPU_CAVIUM_OCTEON

On Mon, May 20, 2013 at 03:19:38PM -0700, David Daney wrote:
>  config OCTEON_MGMT_ETHERNET
>  	tristate "Octeon Management port ethernet driver (CN5XXX, CN6XXX)"
> -	depends on  CPU_CAVIUM_OCTEON
> +	depends on  CAVIUM_OCTEON_SOC

>  config MDIO_OCTEON
>  	tristate "Support for MDIO buses on Octeon SOCs"
> -	depends on  CPU_CAVIUM_OCTEON
> +	depends on  CAVIUM_OCTEON_SOC

>  config USB_OCTEON_OHCI
>  	bool "Octeon on-chip OHCI support"
> -	depends on CPU_CAVIUM_OCTEON
> +	depends on  CAVIUM_OCTEON_SOC

Just a minor comment, here the extra whitespace after "depends on"
could be eliminated.

A.
