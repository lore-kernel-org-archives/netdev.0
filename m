From: Milton Miller <miltonm@bga.com>
Subject: Re: [5/5] Remove REDWOOD_5 and REDWOOD_6 config options and conditional code
Date: Thu, 15 Jul 2010 02:42:07 -0500
Message-ID: <redwood56-reply-1-miltonm@bga.com>
References: <4f07b3092cafbbba37d61d367cc7484e24d18d2a.1279116162.git.qy03fugy@stud.informatik.uni-erlangen.de>
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Solomon Peachy <solomon@linux-wlan.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Artem Bityutskiy <Artem.Bityutskiy@nokia.com>,
	Alexander Kurz <linux@kbdbabel.org>,
	John Linn <john.linn@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Florian Fainelli <florian@openwrt.org>,
	<linuxppc-dev@ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<linux-mtd@lists.infradead.org>, <netdev@vger.kernel.org>,
	<vamos-dev@i4.informatik.uni-erlangen.de>
To: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4f07b3092cafbbba37d61d367cc7484e24d18d2a.1279116162.git.qy03fugy@stud.informatik.uni-erlangen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jul 2010 about 04:05:05 -0000, Christian Dietrich wrote:
> 
> The config options for REDWOOD_[56] were commented out in the powerpc
> Kconfig. The ifdefs referencing this options therefore are dead and all
> references to this can be removed (Also dependencies in other KConfig
> files).
> 
> Signed-off-by: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
> 
> ---
> arch/powerpc/platforms/40x/Kconfig |   16 -------------
>  drivers/mtd/maps/Kconfig           |    2 +-
>  drivers/mtd/maps/redwood.c         |   43 ------------------------------------
>  drivers/net/Kconfig                |    2 +-
>  4 files changed, 2 insertions(+), 61 deletions(-)

> diff --git a/drivers/mtd/maps/Kconfig b/drivers/mtd/maps/Kconfig
> index f22bc9f..b5ebb72 100644
> --- a/drivers/mtd/maps/Kconfig
> +++ b/drivers/mtd/maps/Kconfig
> @@ -321,7 +321,7 @@ config MTD_CFI_FLAGADM
>  
>  config MTD_REDWOOD
>  	tristate "CFI Flash devices mapped on IBM Redwood"
> -	depends on MTD_CFI && ( REDWOOD_4 || REDWOOD_5 || REDWOOD_6 )
> +	depends on MTD_CFI && REDWOOD_4
>  	help
>  	  This enables access routines for the flash chips on the IBM
>  	  Redwood board. If you have one of these boards and would like to

REDWOOD_4 does not appear to be in the tree either so this mapping driver
should be deleted if the patch is otherwise acceptable.  Besides we
would express the info contained in this simple map driver the device tree
using physmap_of.

milton
