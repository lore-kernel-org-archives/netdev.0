From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 136/493] ethernet: remove use of __devexit_p
Date: Tue, 20 Nov 2012 10:31:18 +0100
Message-ID: <50AB4DE6.2070005@atmel.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu> <1353349642-3677-136-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <gregkh@linuxfoundation.org>, <linux-mips@linux-mips.org>,
        Chris Snook <chris.snook@gmail.com>,
        David Dillow <dave@thedillows.org>,
        Jaroslav Kysela <perex@perex.cz>,
        Daniele Venzano <venza@brownhat.org>,
        Samuel Chessman <chessman@tux.org>,
        Stephen Hemminger <shemminger@vyatta.com>,
        John Linn <John.Linn@xilinx.com>,
        Russell King <linux@arm.linux.org.uk>,
        <e1000-devel@lists.sourceforge.net>,
        Guo-Fu Tseng <cooldavid@cooldavid.org>,
        <linux-acenic@sunsite.dk>, Francois Romieu <romieu@fr.zoreil.com>,
        "Steve Glendinning" <steve.glendinning@shawell.net>,
        Jes Sorensen <jes@trained-monkey.org>,
        Jay Cliburn <jcliburn@gmail.com>,
        "Realtek linux nic maintainers" <nic_swsd@realtek.com>,
        Grant Grundler <grundler@parisc-linux.org>,
        Wan ZongShun <mcuos.com@gmail.com>
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1353349642-3677-136-git-send-email-wfp5p@virginia.edu>
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

On 11/19/2012 07:21 PM, Bill Pemberton :
> CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
> needed.
> 
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de> 
> Cc: David Dillow <dave@thedillows.org> 
> Cc: Russell King <linux@arm.linux.org.uk> 
> Cc: Kristoffer Glembo <kristoffer@gaisler.com> 
> Cc: Jes Sorensen <jes@trained-monkey.org> 
> Cc: Don Fry <pcnet32@frontier.com> 
> Cc: Jay Cliburn <jcliburn@gmail.com> 
> Cc: Chris Snook <chris.snook@gmail.com> 
> Cc: Grant Grundler <grundler@parisc-linux.org> 
> Cc: Jaroslav Kysela <perex@perex.cz> 
> Cc: Francois Romieu <romieu@fr.zoreil.com> 
> Cc: Sorbica Shieh <sorbica@icplus.com.tw> 
> Cc: Guo-Fu Tseng <cooldavid@cooldavid.org> 
> Cc: Mirko Lindner <mlindner@marvell.com> 
> Cc: Stephen Hemminger <shemminger@vyatta.com> 
> Cc: Wan ZongShun <mcuos.com@gmail.com> 
> Cc: Olof Johansson <olof@lixom.net> 
> Cc: Florian Fainelli <florian@openwrt.org> 
> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com> 
> Cc: Ralf Baechle <ralf@linux-mips.org> 
> Cc: Daniele Venzano <venza@brownhat.org> 
> Cc: Steve Glendinning <steve.glendinning@shawell.net> 
> Cc: Samuel Chessman <chessman@tux.org> 
> Cc: Roger Luethi <rl@hellgate.ch> 
> Cc: Anirudha Sarangi <anirudh@xilinx.com> 
> Cc: John Linn <John.Linn@xilinx.com> 
> Cc: netdev@vger.kernel.org 
> Cc: linux-arm-kernel@lists.infradead.org 
> Cc: uclinux-dist-devel@blackfin.uclinux.org 
> Cc: linux-acenic@sunsite.dk 
> Cc: e1000-devel@lists.sourceforge.net 
> Cc: linux-mips@linux-mips.org 
> ---


>  drivers/net/ethernet/cadence/at91_ether.c            | 2 +-

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>


> diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
> index 1a8eef2..7d7cd67 100644
> --- a/drivers/net/ethernet/3com/3c509.c
> +++ b/drivers/net/ethernet/3com/3c509.c
> @@ -382,7 +382,7 @@ static int el3_isa_resume(struct device *dev, unsigned int n)
>  
>  static struct isa_driver el3_isa_driver = {
>  	.match		= el3_isa_match,
> -	.remove		= __devexit_p(el3_isa_remove),
> +	.remove		= el3_isa_remove,
>  #ifdef CONFIG_PM
>  	.suspend	= el3_isa_suspend,
>  	.resume		= el3_isa_resume,
> @@ -467,7 +467,7 @@ static struct pnp_driver el3_pnp_driver = {
>  	.name		= "3c509",
>  	.id_table	= el3_pnp_ids,
>  	.probe		= el3_pnp_probe,
> -	.remove		= __devexit_p(el3_pnp_remove),
> +	.remove		= el3_pnp_remove,
>  #ifdef CONFIG_PM
>  	.suspend	= el3_pnp_suspend,
>  	.resume		= el3_pnp_resume,
> @@ -496,7 +496,7 @@ static struct eisa_driver el3_eisa_driver = {
>  		.driver   = {
>  				.name    = "3c579",
>  				.probe   = el3_eisa_probe,
> -				.remove  = __devexit_p (el3_device_remove),
> +				.remove  = el3_device_remove,
>  				.suspend = el3_suspend,
>  				.resume  = el3_resume,
>  		}
> diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
> index e463d10..7cff8b8 100644
> --- a/drivers/net/ethernet/3com/3c59x.c
> +++ b/drivers/net/ethernet/3com/3c59x.c
> @@ -962,7 +962,7 @@ static struct eisa_driver vortex_eisa_driver = {
>  	.driver   = {
>  		.name    = "3c59x",
>  		.probe   = vortex_eisa_probe,
> -		.remove  = __devexit_p(vortex_eisa_remove)
> +		.remove  = vortex_eisa_remove
>  	}
>  };
>  
> @@ -3265,7 +3265,7 @@ static void __devexit vortex_remove_one(struct pci_dev *pdev)
>  static struct pci_driver vortex_driver = {
>  	.name		= "3c59x",
>  	.probe		= vortex_init_one,
> -	.remove		= __devexit_p(vortex_remove_one),
> +	.remove		= vortex_remove_one,
>  	.id_table	= vortex_pci_tbl,
>  	.driver.pm	= VORTEX_PM_OPS,
>  };
> diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
> index bb9670f..e11b27f 100644
> --- a/drivers/net/ethernet/3com/typhoon.c
> +++ b/drivers/net/ethernet/3com/typhoon.c
> @@ -2533,7 +2533,7 @@ static struct pci_driver typhoon_driver = {
>  	.name		= KBUILD_MODNAME,
>  	.id_table	= typhoon_pci_tbl,
>  	.probe		= typhoon_init_one,
> -	.remove		= __devexit_p(typhoon_remove_one),
> +	.remove		= typhoon_remove_one,
>  #ifdef CONFIG_PM
>  	.suspend	= typhoon_suspend,
>  	.resume		= typhoon_resume,
> diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
> index 8322c54..96ed50d 100644
> --- a/drivers/net/ethernet/8390/etherh.c
> +++ b/drivers/net/ethernet/8390/etherh.c
> @@ -839,7 +839,7 @@ static const struct ecard_id etherh_ids[] = {
>  
>  static struct ecard_driver etherh_driver = {
>  	.probe		= etherh_probe,
> -	.remove		= __devexit_p(etherh_remove),
> +	.remove		= etherh_remove,
>  	.id_table	= etherh_ids,
>  	.drv = {
>  		.name	= DRV_NAME,
> diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
> index 5e8845f..8f09fd99 100644
> --- a/drivers/net/ethernet/8390/ne2k-pci.c
> +++ b/drivers/net/ethernet/8390/ne2k-pci.c
> @@ -696,7 +696,7 @@ static int ne2k_pci_resume (struct pci_dev *pdev)
>  static struct pci_driver ne2k_driver = {
>  	.name		= DRV_NAME,
>  	.probe		= ne2k_pci_init_one,
> -	.remove		= __devexit_p(ne2k_pci_remove_one),
> +	.remove		= ne2k_pci_remove_one,
>  	.id_table	= ne2k_pci_tbl,
>  #ifdef CONFIG_PM
>  	.suspend	= ne2k_pci_suspend,
> diff --git a/drivers/net/ethernet/8390/ne3210.c b/drivers/net/ethernet/8390/ne3210.c
> index e3f5742..8579e2f 100644
> --- a/drivers/net/ethernet/8390/ne3210.c
> +++ b/drivers/net/ethernet/8390/ne3210.c
> @@ -324,7 +324,7 @@ static struct eisa_driver ne3210_eisa_driver = {
>  	.driver   = {
>  		.name   = "ne3210",
>  		.probe  = ne3210_eisa_probe,
> -		.remove = __devexit_p (ne3210_eisa_remove),
> +		.remove = ne3210_eisa_remove,
>  	},
>  };
>  
> diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
> index 7818e63..9a041a6 100644
> --- a/drivers/net/ethernet/8390/zorro8390.c
> +++ b/drivers/net/ethernet/8390/zorro8390.c
> @@ -432,7 +432,7 @@ static struct zorro_driver zorro8390_driver = {
>  	.name		= "zorro8390",
>  	.id_table	= zorro8390_zorro_tbl,
>  	.probe		= zorro8390_init_one,
> -	.remove		= __devexit_p(zorro8390_remove_one),
> +	.remove		= zorro8390_remove_one,
>  };
>  
>  static int __init zorro8390_init_module(void)
> diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
> index 5b65992c..e986818 100644
> --- a/drivers/net/ethernet/adaptec/starfire.c
> +++ b/drivers/net/ethernet/adaptec/starfire.c
> @@ -2018,7 +2018,7 @@ static void __devexit starfire_remove_one (struct pci_dev *pdev)
>  static struct pci_driver starfire_driver = {
>  	.name		= DRV_NAME,
>  	.probe		= starfire_init_one,
> -	.remove		= __devexit_p(starfire_remove_one),
> +	.remove		= starfire_remove_one,
>  #ifdef CONFIG_PM
>  	.suspend	= starfire_suspend,
>  	.resume		= starfire_resume,
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
> index f1c458d..cfcce5b 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -1881,7 +1881,7 @@ static int __devexit bfin_mii_bus_remove(struct platform_device *pdev)
>  
>  static struct platform_driver bfin_mii_bus_driver = {
>  	.probe = bfin_mii_bus_probe,
> -	.remove = __devexit_p(bfin_mii_bus_remove),
> +	.remove = bfin_mii_bus_remove,
>  	.driver = {
>  		.name = "bfin_mii_bus",
>  		.owner	= THIS_MODULE,
> @@ -1890,7 +1890,7 @@ static struct platform_driver bfin_mii_bus_driver = {
>  
>  static struct platform_driver bfin_mac_driver = {
>  	.probe = bfin_mac_probe,
> -	.remove = __devexit_p(bfin_mac_remove),
> +	.remove = bfin_mac_remove,
>  	.resume = bfin_mac_resume,
>  	.suspend = bfin_mac_suspend,
>  	.driver = {
> diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
> index 9c77c73..3629690 100644
> --- a/drivers/net/ethernet/aeroflex/greth.c
> +++ b/drivers/net/ethernet/aeroflex/greth.c
> @@ -1619,7 +1619,7 @@ static struct platform_driver greth_of_driver = {
>  		.of_match_table = greth_of_match,
>  	},
>  	.probe = greth_of_probe,
> -	.remove = __devexit_p(greth_of_remove),
> +	.remove = greth_of_remove,
>  };
>  
>  module_platform_driver(greth_of_driver);
> diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
> index 7219123..9cb94b3 100644
> --- a/drivers/net/ethernet/alteon/acenic.c
> +++ b/drivers/net/ethernet/alteon/acenic.c
> @@ -699,7 +699,7 @@ static struct pci_driver acenic_pci_driver = {
>  	.name		= "acenic",
>  	.id_table	= acenic_pci_tbl,
>  	.probe		= acenic_probe_one,
> -	.remove		= __devexit_p(acenic_remove_one),
> +	.remove		= acenic_remove_one,
>  };
>  
>  static int __init acenic_init(void)
> diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
> index 689dfca..2745c0a 100644
> --- a/drivers/net/ethernet/amd/a2065.c
> +++ b/drivers/net/ethernet/amd/a2065.c
> @@ -656,7 +656,7 @@ static struct zorro_driver a2065_driver = {
>  	.name		= "a2065",
>  	.id_table	= a2065_zorro_tbl,
>  	.probe		= a2065_init_one,
> -	.remove		= __devexit_p(a2065_remove_one),
> +	.remove		= a2065_remove_one,
>  };
>  
>  static const struct net_device_ops lance_netdev_ops = {
> diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
> index 3491d43..5891636 100644
> --- a/drivers/net/ethernet/amd/amd8111e.c
> +++ b/drivers/net/ethernet/amd/amd8111e.c
> @@ -1976,7 +1976,7 @@ static struct pci_driver amd8111e_driver = {
>  	.name   	= MODULE_NAME,
>  	.id_table	= amd8111e_pci_tbl,
>  	.probe		= amd8111e_probe_one,
> -	.remove		= __devexit_p(amd8111e_remove_one),
> +	.remove		= amd8111e_remove_one,
>  	.suspend	= amd8111e_suspend,
>  	.resume		= amd8111e_resume
>  };
> diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
> index f2958df9..72b56a8 100644
> --- a/drivers/net/ethernet/amd/ariadne.c
> +++ b/drivers/net/ethernet/amd/ariadne.c
> @@ -774,7 +774,7 @@ static struct zorro_driver ariadne_driver = {
>  	.name		= "ariadne",
>  	.id_table	= ariadne_zorro_tbl,
>  	.probe		= ariadne_init_one,
> -	.remove		= __devexit_p(ariadne_remove_one),
> +	.remove		= ariadne_remove_one,
>  };
>  
>  static int __init ariadne_init_module(void)
> diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
> index f195acf..cbbfdc9 100644
> --- a/drivers/net/ethernet/amd/au1000_eth.c
> +++ b/drivers/net/ethernet/amd/au1000_eth.c
> @@ -1340,7 +1340,7 @@ static int __devexit au1000_remove(struct platform_device *pdev)
>  
>  static struct platform_driver au1000_eth_driver = {
>  	.probe  = au1000_probe,
> -	.remove = __devexit_p(au1000_remove),
> +	.remove = au1000_remove,
>  	.driver = {
>  		.name   = "au1000-eth",
>  		.owner  = THIS_MODULE,
> diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
> index c771de7..8a86c06 100644
> --- a/drivers/net/ethernet/amd/depca.c
> +++ b/drivers/net/ethernet/amd/depca.c
> @@ -338,7 +338,7 @@ static struct eisa_driver depca_eisa_driver = {
>  	.driver   = {
>  		.name    = depca_string,
>  		.probe   = depca_eisa_probe,
> -		.remove  = __devexit_p (depca_device_remove)
> +		.remove  = depca_device_remove
>  	}
>  };
>  #endif
> @@ -352,7 +352,7 @@ static int __devexit depca_isa_remove(struct platform_device *pdev)
>  
>  static struct platform_driver depca_isa_driver = {
>  	.probe  = depca_isa_probe,
> -	.remove = __devexit_p(depca_isa_remove),
> +	.remove = depca_isa_remove,
>  	.driver	= {
>  		.name   = depca_string,
>  	},
> diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
> index 8baff4e..1b2d4a1 100644
> --- a/drivers/net/ethernet/amd/hplance.c
> +++ b/drivers/net/ethernet/amd/hplance.c
> @@ -66,7 +66,7 @@ static struct dio_driver hplance_driver = {
>  	.name      = "hplance",
>  	.id_table  = hplance_dio_tbl,
>  	.probe     = hplance_init_one,
> -	.remove    = __devexit_p(hplance_remove_one),
> +	.remove    = hplance_remove_one,
>  };
>  
>  static const struct net_device_ops hplance_netdev_ops = {
> diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
> index 86b6d8e..d16fcd8 100644
> --- a/drivers/net/ethernet/amd/pcnet32.c
> +++ b/drivers/net/ethernet/amd/pcnet32.c
> @@ -2844,7 +2844,7 @@ static void __devexit pcnet32_remove_one(struct pci_dev *pdev)
>  static struct pci_driver pcnet32_driver = {
>  	.name = DRV_NAME,
>  	.probe = pcnet32_probe_pci,
> -	.remove = __devexit_p(pcnet32_remove_one),
> +	.remove = pcnet32_remove_one,
>  	.id_table = pcnet32_pci_tbl,
>  	.suspend = pcnet32_pm_suspend,
>  	.resume = pcnet32_pm_resume,
> diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
> index d7a3533..d794921 100644
> --- a/drivers/net/ethernet/amd/sunlance.c
> +++ b/drivers/net/ethernet/amd/sunlance.c
> @@ -1536,7 +1536,7 @@ static struct platform_driver sunlance_sbus_driver = {
>  		.of_match_table = sunlance_sbus_match,
>  	},
>  	.probe		= sunlance_sbus_probe,
> -	.remove		= __devexit_p(sunlance_sbus_remove),
> +	.remove		= sunlance_sbus_remove,
>  };
>  
>  module_platform_driver(sunlance_sbus_driver);
> diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
> index a92ddee7..c2e9ef6 100644
> --- a/drivers/net/ethernet/apple/macmace.c
> +++ b/drivers/net/ethernet/apple/macmace.c
> @@ -768,7 +768,7 @@ static int __devexit mac_mace_device_remove (struct platform_device *pdev)
>  
>  static struct platform_driver mac_mace_driver = {
>  	.probe  = mace_probe,
> -	.remove = __devexit_p(mac_mace_device_remove),
> +	.remove = mac_mace_device_remove,
>  	.driver	= {
>  		.name	= mac_mace_string,
>  		.owner	= THIS_MODULE,
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index d19f82f..edb5d6e 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -2697,7 +2697,7 @@ static struct pci_driver atl1c_driver = {
>  	.name     = atl1c_driver_name,
>  	.id_table = atl1c_pci_tbl,
>  	.probe    = atl1c_probe,
> -	.remove   = __devexit_p(atl1c_remove),
> +	.remove   = atl1c_remove,
>  	.shutdown = atl1c_shutdown,
>  	.err_handler = &atl1c_err_handler,
>  	.driver.pm = &atl1c_pm_ops,
> diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> index e213da2..eacf624 100644
> --- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> +++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> @@ -2499,7 +2499,7 @@ static struct pci_driver atl1e_driver = {
>  	.name     = atl1e_driver_name,
>  	.id_table = atl1e_pci_tbl,
>  	.probe    = atl1e_probe,
> -	.remove   = __devexit_p(atl1e_remove),
> +	.remove   = atl1e_remove,
>  	/* Power Management Hooks */
>  #ifdef CONFIG_PM
>  	.suspend  = atl1e_suspend,
> diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
> index 7bae2ad..b396907 100644
> --- a/drivers/net/ethernet/atheros/atlx/atl1.c
> +++ b/drivers/net/ethernet/atheros/atlx/atl1.c
> @@ -3146,7 +3146,7 @@ static struct pci_driver atl1_driver = {
>  	.name = ATLX_DRIVER_NAME,
>  	.id_table = atl1_pci_tbl,
>  	.probe = atl1_probe,
> -	.remove = __devexit_p(atl1_remove),
> +	.remove = atl1_remove,
>  	.shutdown = atl1_shutdown,
>  	.driver.pm = ATL1_PM_OPS,
>  };
> diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
> index 623dd86..0988200 100644
> --- a/drivers/net/ethernet/atheros/atlx/atl2.c
> +++ b/drivers/net/ethernet/atheros/atlx/atl2.c
> @@ -1705,7 +1705,7 @@ static struct pci_driver atl2_driver = {
>  	.name     = atl2_driver_name,
>  	.id_table = atl2_pci_tbl,
>  	.probe    = atl2_probe,
> -	.remove   = __devexit_p(atl2_remove),
> +	.remove   = atl2_remove,
>  	/* Power Management Hooks */
>  	.suspend  = atl2_suspend,
>  #ifdef CONFIG_PM
> diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
> index 9786c0e..94fa5d8 100644
> --- a/drivers/net/ethernet/broadcom/b44.c
> +++ b/drivers/net/ethernet/broadcom/b44.c
> @@ -2340,7 +2340,7 @@ static struct ssb_driver b44_ssb_driver = {
>  	.name		= DRV_MODULE_NAME,
>  	.id_table	= b44_ssb_tbl,
>  	.probe		= b44_init_one,
> -	.remove		= __devexit_p(b44_remove_one),
> +	.remove		= b44_remove_one,
>  	.suspend	= b44_suspend,
>  	.resume		= b44_resume,
>  };
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> index c7ca7ec..f062656 100644
> --- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> +++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> @@ -1877,7 +1877,7 @@ static int __devexit bcm_enet_remove(struct platform_device *pdev)
>  
>  struct platform_driver bcm63xx_enet_driver = {
>  	.probe	= bcm_enet_probe,
> -	.remove	= __devexit_p(bcm_enet_remove),
> +	.remove	= bcm_enet_remove,
>  	.driver	= {
>  		.name	= "bcm63xx_enet",
>  		.owner  = THIS_MODULE,
> @@ -1924,7 +1924,7 @@ static int __devexit bcm_enet_shared_remove(struct platform_device *pdev)
>   */
>  struct platform_driver bcm63xx_enet_shared_driver = {
>  	.probe	= bcm_enet_shared_probe,
> -	.remove	= __devexit_p(bcm_enet_shared_remove),
> +	.remove	= bcm_enet_shared_remove,
>  	.driver	= {
>  		.name	= "bcm63xx_enet_shared",
>  		.owner  = THIS_MODULE,
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index d431070..7b55f78 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -8752,7 +8752,7 @@ static struct pci_driver bnx2_pci_driver = {
>  	.name		= DRV_MODULE_NAME,
>  	.id_table	= bnx2_pci_tbl,
>  	.probe		= bnx2_init_one,
> -	.remove		= __devexit_p(bnx2_remove_one),
> +	.remove		= bnx2_remove_one,
>  	.suspend	= bnx2_suspend,
>  	.resume		= bnx2_resume,
>  	.err_handler	= &bnx2_err_handler,
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 3519fed..d9e72fcb 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -12349,7 +12349,7 @@ static struct pci_driver bnx2x_pci_driver = {
>  	.name        = DRV_MODULE_NAME,
>  	.id_table    = bnx2x_pci_tbl,
>  	.probe       = bnx2x_init_one,
> -	.remove      = __devexit_p(bnx2x_remove_one),
> +	.remove      = bnx2x_remove_one,
>  	.suspend     = bnx2x_suspend,
>  	.resume      = bnx2x_resume,
>  	.err_handler = &bnx2x_err_handler,
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 038ce02..d752b10 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -16567,7 +16567,7 @@ static struct pci_driver tg3_driver = {
>  	.name		= DRV_MODULE_NAME,
>  	.id_table	= tg3_pci_tbl,
>  	.probe		= tg3_init_one,
> -	.remove		= __devexit_p(tg3_remove_one),
> +	.remove		= tg3_remove_one,
>  	.err_handler	= &tg3_err_handler,
>  	.driver.pm	= TG3_PM_OPS,
>  };
> diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
> index ce1eac5..7735469 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad.c
> @@ -3490,7 +3490,7 @@ static struct pci_driver bnad_pci_driver = {
>  	.name = BNAD_NAME,
>  	.id_table = bnad_pci_id_table,
>  	.probe = bnad_pci_probe,
> -	.remove = __devexit_p(bnad_pci_remove),
> +	.remove = bnad_pci_remove,
>  };
>  
>  static int __init
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> index e7a476c..fdf7985 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -512,7 +512,7 @@ static int at91ether_resume(struct platform_device *pdev)
>  #endif
>  
>  static struct platform_driver at91ether_driver = {
> -	.remove		= __devexit_p(at91ether_remove),
> +	.remove		= at91ether_remove,
>  	.suspend	= at91ether_suspend,
>  	.resume		= at91ether_resume,
>  	.driver		= {
> diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
> index 1d17c92..7cfa7bb 100644
> --- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
> +++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
> @@ -1361,7 +1361,7 @@ static struct pci_driver driver = {
>  	.name     = DRV_NAME,
>  	.id_table = t1_pci_tbl,
>  	.probe    = init_one,
> -	.remove   = __devexit_p(remove_one),
> +	.remove   = remove_one,
>  };
>  
>  static int __init t1_init_module(void)
> diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
> index 9c9f326..a450f8d 100644
> --- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
> @@ -3425,7 +3425,7 @@ static struct pci_driver driver = {
>  	.name = DRV_NAME,
>  	.id_table = cxgb3_pci_tbl,
>  	.probe = init_one,
> -	.remove = __devexit_p(remove_one),
> +	.remove = remove_one,
>  	.err_handler = &t3_err_handler,
>  };
>  
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index 0df1284..f344190 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -4680,7 +4680,7 @@ static struct pci_driver cxgb4_driver = {
>  	.name     = KBUILD_MODNAME,
>  	.id_table = cxgb4_pci_tbl,
>  	.probe    = init_one,
> -	.remove   = __devexit_p(remove_one),
> +	.remove   = remove_one,
>  	.err_handler = &cxgb4_eeh,
>  };
>  
> diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> index 9dad561..1ccd28b 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> @@ -2905,8 +2905,8 @@ static struct pci_driver cxgb4vf_driver = {
>  	.name		= KBUILD_MODNAME,
>  	.id_table	= cxgb4vf_pci_tbl,
>  	.probe		= cxgb4vf_pci_probe,
> -	.remove		= __devexit_p(cxgb4vf_pci_remove),
> -	.shutdown	= __devexit_p(cxgb4vf_pci_shutdown),
> +	.remove		= cxgb4vf_pci_remove,
> +	.shutdown	= cxgb4vf_pci_shutdown,
>  };
>  
>  /*
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index ad1468b..612438a 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -2584,7 +2584,7 @@ static struct pci_driver enic_driver = {
>  	.name = DRV_NAME,
>  	.id_table = enic_id_table,
>  	.probe = enic_probe,
> -	.remove = __devexit_p(enic_remove),
> +	.remove = enic_remove,
>  };
>  
>  static int __init enic_init_module(void)
> diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
> index 36499d5..87d7c35 100644
> --- a/drivers/net/ethernet/davicom/dm9000.c
> +++ b/drivers/net/ethernet/davicom/dm9000.c
> @@ -1683,7 +1683,7 @@ static struct platform_driver dm9000_driver = {
>  		.pm	 = &dm9000_drv_pm_ops,
>  	},
>  	.probe   = dm9000_probe,
> -	.remove  = __devexit_p(dm9000_drv_remove),
> +	.remove  = dm9000_drv_remove,
>  };
>  
>  static int __init
> diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
> index 77335853..18fd028 100644
> --- a/drivers/net/ethernet/dec/tulip/de2104x.c
> +++ b/drivers/net/ethernet/dec/tulip/de2104x.c
> @@ -2184,7 +2184,7 @@ static struct pci_driver de_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= de_pci_tbl,
>  	.probe		= de_init_one,
> -	.remove		= __devexit_p(de_remove_one),
> +	.remove		= de_remove_one,
>  #ifdef CONFIG_PM
>  	.suspend	= de_suspend,
>  	.resume		= de_resume,
> diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
> index f879e92..8a4264f 100644
> --- a/drivers/net/ethernet/dec/tulip/de4x5.c
> +++ b/drivers/net/ethernet/dec/tulip/de4x5.c
> @@ -2104,7 +2104,7 @@ static struct eisa_driver de4x5_eisa_driver = {
>          .driver   = {
>                  .name    = "de4x5",
>                  .probe   = de4x5_eisa_probe,
> -                .remove  = __devexit_p (de4x5_eisa_remove),
> +		.remove	 = de4x5_eisa_remove,
>          }
>  };
>  MODULE_DEVICE_TABLE(eisa, de4x5_eisa_ids);
> @@ -2344,7 +2344,7 @@ static struct pci_driver de4x5_pci_driver = {
>          .name           = "de4x5",
>          .id_table       = de4x5_pci_tbl,
>          .probe          = de4x5_pci_probe,
> -	.remove         = __devexit_p (de4x5_pci_remove),
> +	.remove         = de4x5_pci_remove,
>  };
>  
>  #endif
> diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
> index d23755e..a631448 100644
> --- a/drivers/net/ethernet/dec/tulip/dmfe.c
> +++ b/drivers/net/ethernet/dec/tulip/dmfe.c
> @@ -2187,7 +2187,7 @@ static struct pci_driver dmfe_driver = {
>  	.name		= "dmfe",
>  	.id_table	= dmfe_pci_tbl,
>  	.probe		= dmfe_init_one,
> -	.remove		= __devexit_p(dmfe_remove_one),
> +	.remove		= dmfe_remove_one,
>  	.suspend        = dmfe_suspend,
>  	.resume         = dmfe_resume
>  };
> diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
> index 885700a..2a3736e 100644
> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
> @@ -1974,7 +1974,7 @@ static struct pci_driver tulip_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= tulip_pci_tbl,
>  	.probe		= tulip_init_one,
> -	.remove		= __devexit_p(tulip_remove_one),
> +	.remove		= tulip_remove_one,
>  #ifdef CONFIG_PM
>  	.suspend	= tulip_suspend,
>  	.resume		= tulip_resume,
> diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
> index 75d45f8..9c24c95 100644
> --- a/drivers/net/ethernet/dec/tulip/uli526x.c
> +++ b/drivers/net/ethernet/dec/tulip/uli526x.c
> @@ -1788,7 +1788,7 @@ static struct pci_driver uli526x_driver = {
>  	.name		= "uli526x",
>  	.id_table	= uli526x_pci_tbl,
>  	.probe		= uli526x_init_one,
> -	.remove		= __devexit_p(uli526x_remove_one),
> +	.remove		= uli526x_remove_one,
>  	.suspend	= uli526x_suspend,
>  	.resume		= uli526x_resume,
>  };
> diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
> index 7c1ec4d..6c5db4f 100644
> --- a/drivers/net/ethernet/dec/tulip/winbond-840.c
> +++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
> @@ -1647,7 +1647,7 @@ static struct pci_driver w840_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= w840_pci_tbl,
>  	.probe		= w840_probe1,
> -	.remove		= __devexit_p(w840_remove1),
> +	.remove		= w840_remove1,
>  #ifdef CONFIG_PM
>  	.suspend	= w840_suspend,
>  	.resume		= w840_resume,
> diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
> index 138bf83..4310e97 100644
> --- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
> +++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
> @@ -148,7 +148,7 @@ static struct pci_driver xircom_ops = {
>  	.name		= "xircom_cb",
>  	.id_table	= xircom_pci_table,
>  	.probe		= xircom_probe,
> -	.remove		= __devexit_p(xircom_remove),
> +	.remove		= xircom_remove,
>  };
>  
>  
> diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
> index 2fb01bf..21db34c 100644
> --- a/drivers/net/ethernet/dlink/dl2k.c
> +++ b/drivers/net/ethernet/dlink/dl2k.c
> @@ -1755,7 +1755,7 @@ static struct pci_driver rio_driver = {
>  	.name		= "dl2k",
>  	.id_table	= rio_pci_tbl,
>  	.probe		= rio_probe1,
> -	.remove		= __devexit_p(rio_remove1),
> +	.remove		= rio_remove1,
>  };
>  
>  module_pci_driver(rio_driver);
> diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
> index 3b83588..65187b9 100644
> --- a/drivers/net/ethernet/dlink/sundance.c
> +++ b/drivers/net/ethernet/dlink/sundance.c
> @@ -1910,7 +1910,7 @@ static struct pci_driver sundance_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= sundance_pci_tbl,
>  	.probe		= sundance_probe1,
> -	.remove		= __devexit_p(sundance_remove1),
> +	.remove		= sundance_remove1,
>  #ifdef CONFIG_PM
>  	.suspend	= sundance_suspend,
>  	.resume		= sundance_resume,
> diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
> index 290b26f..dfdf553 100644
> --- a/drivers/net/ethernet/dnet.c
> +++ b/drivers/net/ethernet/dnet.c
> @@ -971,7 +971,7 @@ static int __devexit dnet_remove(struct platform_device *pdev)
>  
>  static struct platform_driver dnet_driver = {
>  	.probe		= dnet_probe,
> -	.remove		= __devexit_p(dnet_remove),
> +	.remove		= dnet_remove,
>  	.driver		= {
>  		.name		= "dnet",
>  	},
> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
> index 94b7bfc..198d587 100644
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> @@ -1190,7 +1190,7 @@ MODULE_DEVICE_TABLE(of, ethoc_match);
>  
>  static struct platform_driver ethoc_driver = {
>  	.probe   = ethoc_probe,
> -	.remove  = __devexit_p(ethoc_remove),
> +	.remove  = ethoc_remove,
>  	.suspend = ethoc_suspend,
>  	.resume  = ethoc_resume,
>  	.driver  = {
> diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
> index 0e4a0ac..fce1d35 100644
> --- a/drivers/net/ethernet/fealnx.c
> +++ b/drivers/net/ethernet/fealnx.c
> @@ -1950,7 +1950,7 @@ static struct pci_driver fealnx_driver = {
>  	.name		= "fealnx",
>  	.id_table	= fealnx_pci_tbl,
>  	.probe		= fealnx_init_one,
> -	.remove		= __devexit_p(fealnx_remove_one),
> +	.remove		= fealnx_remove_one,
>  };
>  
>  static int __init fealnx_init(void)
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index 2665162..3729996 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -1790,7 +1790,7 @@ static struct platform_driver fec_driver = {
>  	},
>  	.id_table = fec_devtype,
>  	.probe	= fec_probe,
> -	.remove	= __devexit_p(fec_drv_remove),
> +	.remove	= fec_drv_remove,
>  };
>  
>  module_platform_driver(fec_driver);
> diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
> index 3f4391b..9aba3fb 100644
> --- a/drivers/net/ethernet/hp/hp100.c
> +++ b/drivers/net/ethernet/hp/hp100.c
> @@ -2878,7 +2878,7 @@ static struct eisa_driver hp100_eisa_driver = {
>          .driver   = {
>                  .name    = "hp100",
>                  .probe   = hp100_eisa_probe,
> -                .remove  = __devexit_p (hp100_eisa_remove),
> +		.remove	 = hp100_eisa_remove,
>          }
>  };
>  #endif
> @@ -2950,7 +2950,7 @@ static struct pci_driver hp100_pci_driver = {
>  	.name		= "hp100",
>  	.id_table	= hp100_pci_tbl,
>  	.probe		= hp100_pci_probe,
> -	.remove		= __devexit_p(hp100_pci_remove),
> +	.remove		= hp100_pci_remove,
>  };
>  #endif
>  
> diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
> index 067db3f..75a1b57 100644
> --- a/drivers/net/ethernet/i825xx/ether1.c
> +++ b/drivers/net/ethernet/i825xx/ether1.c
> @@ -1070,7 +1070,7 @@ static const struct ecard_id ether1_ids[] = {
>  
>  static struct ecard_driver ether1_driver = {
>  	.probe		= ether1_probe,
> -	.remove		= __devexit_p(ether1_remove),
> +	.remove		= ether1_remove,
>  	.id_table	= ether1_ids,
>  	.drv = {
>  		.name	= "ether1",
> diff --git a/drivers/net/ethernet/i825xx/lasi_82596.c b/drivers/net/ethernet/i825xx/lasi_82596.c
> index 6eba352..a79cc24 100644
> --- a/drivers/net/ethernet/i825xx/lasi_82596.c
> +++ b/drivers/net/ethernet/i825xx/lasi_82596.c
> @@ -219,7 +219,7 @@ static struct parisc_driver lan_driver = {
>  	.name		= "lasi_82596",
>  	.id_table	= lan_tbl,
>  	.probe		= lan_init_chip,
> -	.remove         = __devexit_p(lan_remove_chip),
> +	.remove         = lan_remove_chip,
>  };
>  
>  static int __devinit lasi_82596_init(void)
> diff --git a/drivers/net/ethernet/i825xx/sni_82596.c b/drivers/net/ethernet/i825xx/sni_82596.c
> index 6b2a888..4442c6e 100644
> --- a/drivers/net/ethernet/i825xx/sni_82596.c
> +++ b/drivers/net/ethernet/i825xx/sni_82596.c
> @@ -163,7 +163,7 @@ static int __devexit sni_82596_driver_remove(struct platform_device *pdev)
>  
>  static struct platform_driver sni_82596_driver = {
>  	.probe	= sni_82596_probe,
> -	.remove	= __devexit_p(sni_82596_driver_remove),
> +	.remove	= sni_82596_driver_remove,
>  	.driver	= {
>  		.name	= sni_82596_string,
>  		.owner	= THIS_MODULE,
> diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
> index 1b563bb..549de0e 100644
> --- a/drivers/net/ethernet/icplus/ipg.c
> +++ b/drivers/net/ethernet/icplus/ipg.c
> @@ -2296,7 +2296,7 @@ static struct pci_driver ipg_pci_driver = {
>  	.name		= IPG_DRIVER_NAME,
>  	.id_table	= ipg_pci_tbl,
>  	.probe		= ipg_probe,
> -	.remove		= __devexit_p(ipg_remove),
> +	.remove		= ipg_remove,
>  };
>  
>  static int __init ipg_init_module(void)
> diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
> index 29ce9bd..f41eaed 100644
> --- a/drivers/net/ethernet/intel/e100.c
> +++ b/drivers/net/ethernet/intel/e100.c
> @@ -3167,7 +3167,7 @@ static struct pci_driver e100_driver = {
>  	.name =         DRV_NAME,
>  	.id_table =     e100_id_table,
>  	.probe =        e100_probe,
> -	.remove =       __devexit_p(e100_remove),
> +	.remove =       e100_remove,
>  #ifdef CONFIG_PM
>  	/* Power Management hooks */
>  	.suspend =      e100_suspend,
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 222bfaf..3ca5fd3 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -202,7 +202,7 @@ static struct pci_driver e1000_driver = {
>  	.name     = e1000_driver_name,
>  	.id_table = e1000_pci_tbl,
>  	.probe    = e1000_probe,
> -	.remove   = __devexit_p(e1000_remove),
> +	.remove   = e1000_remove,
>  #ifdef CONFIG_PM
>  	/* Power Management Hooks */
>  	.suspend  = e1000_suspend,
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index dadb13b..2f5bfd3 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -6589,7 +6589,7 @@ static struct pci_driver e1000_driver = {
>  	.name     = e1000e_driver_name,
>  	.id_table = e1000_pci_tbl,
>  	.probe    = e1000_probe,
> -	.remove   = __devexit_p(e1000_remove),
> +	.remove   = e1000_remove,
>  #ifdef CONFIG_PM
>  	.driver   = {
>  		.pm = &e1000_pm_ops,
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 7044aaa..fdb2282 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -228,7 +228,7 @@ static struct pci_driver igb_driver = {
>  	.name     = igb_driver_name,
>  	.id_table = igb_pci_tbl,
>  	.probe    = igb_probe,
> -	.remove   = __devexit_p(igb_remove),
> +	.remove   = igb_remove,
>  #ifdef CONFIG_PM
>  	.driver.pm = &igb_pm_ops,
>  #endif
> diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
> index 4051ec4..935173a 100644
> --- a/drivers/net/ethernet/intel/igbvf/netdev.c
> +++ b/drivers/net/ethernet/intel/igbvf/netdev.c
> @@ -2864,7 +2864,7 @@ static struct pci_driver igbvf_driver = {
>  	.name     = igbvf_driver_name,
>  	.id_table = igbvf_pci_tbl,
>  	.probe    = igbvf_probe,
> -	.remove   = __devexit_p(igbvf_remove),
> +	.remove   = igbvf_remove,
>  #ifdef CONFIG_PM
>  	/* Power Management Hooks */
>  	.suspend  = igbvf_suspend,
> diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
> index d99a2d5..5b44d8a 100644
> --- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
> +++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
> @@ -125,7 +125,7 @@ static struct pci_driver ixgb_driver = {
>  	.name     = ixgb_driver_name,
>  	.id_table = ixgb_pci_tbl,
>  	.probe    = ixgb_probe,
> -	.remove   = __devexit_p(ixgb_remove),
> +	.remove   = ixgb_remove,
>  	.err_handler = &ixgb_err_handler
>  };
>  
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 38fc186..4258ffa 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -7818,7 +7818,7 @@ static struct pci_driver ixgbe_driver = {
>  	.name     = ixgbe_driver_name,
>  	.id_table = ixgbe_pci_tbl,
>  	.probe    = ixgbe_probe,
> -	.remove   = __devexit_p(ixgbe_remove),
> +	.remove   = ixgbe_remove,
>  #ifdef CONFIG_PM
>  	.suspend  = ixgbe_suspend,
>  	.resume   = ixgbe_resume,
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 9d88153..da8b116 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -3557,7 +3557,7 @@ static struct pci_driver ixgbevf_driver = {
>  	.name     = ixgbevf_driver_name,
>  	.id_table = ixgbevf_pci_tbl,
>  	.probe    = ixgbevf_probe,
> -	.remove   = __devexit_p(ixgbevf_remove),
> +	.remove   = ixgbevf_remove,
>  #ifdef CONFIG_PM
>  	/* Power Management Hooks */
>  	.suspend  = ixgbevf_suspend,
> diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
> index 76a91f6..939cddc 100644
> --- a/drivers/net/ethernet/jme.c
> +++ b/drivers/net/ethernet/jme.c
> @@ -3330,7 +3330,7 @@ static struct pci_driver jme_driver = {
>  	.name           = DRV_NAME,
>  	.id_table       = jme_pci_tbl,
>  	.probe          = jme_init_one,
> -	.remove         = __devexit_p(jme_remove_one),
> +	.remove         = jme_remove_one,
>  	.shutdown       = jme_shutdown,
>  	.driver.pm	= JME_PM_OPS,
>  };
> diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
> index 003c5bc..44d4d61 100644
> --- a/drivers/net/ethernet/lantiq_etop.c
> +++ b/drivers/net/ethernet/lantiq_etop.c
> @@ -789,7 +789,7 @@ ltq_etop_remove(struct platform_device *pdev)
>  }
>  
>  static struct platform_driver ltq_mii_driver = {
> -	.remove = __devexit_p(ltq_etop_remove),
> +	.remove = ltq_etop_remove,
>  	.driver = {
>  		.name = "ltq_etop",
>  		.owner = THIS_MODULE,
> diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
> index d19a143..0912768 100644
> --- a/drivers/net/ethernet/marvell/skge.c
> +++ b/drivers/net/ethernet/marvell/skge.c
> @@ -4142,7 +4142,7 @@ static struct pci_driver skge_driver = {
>  	.name =         DRV_NAME,
>  	.id_table =     skge_id_table,
>  	.probe =        skge_probe,
> -	.remove =       __devexit_p(skge_remove),
> +	.remove =       skge_remove,
>  	.shutdown =	skge_shutdown,
>  	.driver.pm =	SKGE_PM_OPS,
>  };
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index 78946fe..3c6314f 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -5207,7 +5207,7 @@ static struct pci_driver sky2_driver = {
>  	.name = DRV_NAME,
>  	.id_table = sky2_id_table,
>  	.probe = sky2_probe,
> -	.remove = __devexit_p(sky2_remove),
> +	.remove = sky2_remove,
>  	.shutdown = sky2_shutdown,
>  	.driver.pm = SKY2_PM_OPS,
>  };
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index 2aa80af..877b74a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2391,7 +2391,7 @@ static struct pci_driver mlx4_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= mlx4_pci_table,
>  	.probe		= mlx4_init_one,
> -	.remove		= __devexit_p(mlx4_remove_one),
> +	.remove		= mlx4_remove_one,
>  	.err_handler    = &mlx4_err_handler,
>  };
>  
> diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
> index dccae1d..786cc0f 100644
> --- a/drivers/net/ethernet/micrel/ks8695net.c
> +++ b/drivers/net/ethernet/micrel/ks8695net.c
> @@ -1620,7 +1620,7 @@ static struct platform_driver ks8695_driver = {
>  		.owner	= THIS_MODULE,
>  	},
>  	.probe		= ks8695_probe,
> -	.remove		= __devexit_p(ks8695_drv_remove),
> +	.remove		= ks8695_drv_remove,
>  	.suspend	= ks8695_drv_suspend,
>  	.resume		= ks8695_drv_resume,
>  };
> diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
> index 24fb049..f84dd2d 100644
> --- a/drivers/net/ethernet/micrel/ks8842.c
> +++ b/drivers/net/ethernet/micrel/ks8842.c
> @@ -1262,7 +1262,7 @@ static struct platform_driver ks8842_platform_driver = {
>  		.owner	= THIS_MODULE,
>  	},
>  	.probe		= ks8842_probe,
> -	.remove		= __devexit_p(ks8842_remove),
> +	.remove		= ks8842_remove,
>  };
>  
>  module_platform_driver(ks8842_platform_driver);
> diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
> index 1540ebe..a1f7d7d 100644
> --- a/drivers/net/ethernet/micrel/ks8851.c
> +++ b/drivers/net/ethernet/micrel/ks8851.c
> @@ -1554,7 +1554,7 @@ static struct spi_driver ks8851_driver = {
>  		.owner = THIS_MODULE,
>  	},
>  	.probe = ks8851_probe,
> -	.remove = __devexit_p(ks8851_remove),
> +	.remove = ks8851_remove,
>  	.suspend = ks8851_suspend,
>  	.resume = ks8851_resume,
>  };
> diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
> index 38529ed..80fe0b3 100644
> --- a/drivers/net/ethernet/micrel/ks8851_mll.c
> +++ b/drivers/net/ethernet/micrel/ks8851_mll.c
> @@ -1663,7 +1663,7 @@ static struct platform_driver ks8851_platform_driver = {
>  		.owner = THIS_MODULE,
>  	},
>  	.probe = ks8851_probe,
> -	.remove = __devexit_p(ks8851_remove),
> +	.remove = ks8851_remove,
>  };
>  
>  module_platform_driver(ks8851_platform_driver);
> diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
> index 6118bda..1373b02 100644
> --- a/drivers/net/ethernet/microchip/enc28j60.c
> +++ b/drivers/net/ethernet/microchip/enc28j60.c
> @@ -1637,7 +1637,7 @@ static struct spi_driver enc28j60_driver = {
>  		   .owner = THIS_MODULE,
>  	 },
>  	.probe = enc28j60_probe,
> -	.remove = __devexit_p(enc28j60_remove),
> +	.remove = enc28j60_remove,
>  };
>  
>  static int __init enc28j60_init(void)
> diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
> index 95dd39f..1b2ed23 100644
> --- a/drivers/net/ethernet/natsemi/jazzsonic.c
> +++ b/drivers/net/ethernet/natsemi/jazzsonic.c
> @@ -286,7 +286,7 @@ static int __devexit jazz_sonic_device_remove (struct platform_device *pdev)
>  
>  static struct platform_driver jazz_sonic_driver = {
>  	.probe	= jazz_sonic_probe,
> -	.remove	= __devexit_p(jazz_sonic_device_remove),
> +	.remove	= jazz_sonic_device_remove,
>  	.driver	= {
>  		.name	= jazz_sonic_string,
>  		.owner	= THIS_MODULE,
> diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
> index b9680ba..1d6a789 100644
> --- a/drivers/net/ethernet/natsemi/macsonic.c
> +++ b/drivers/net/ethernet/natsemi/macsonic.c
> @@ -634,7 +634,7 @@ static int __devexit mac_sonic_device_remove (struct platform_device *pdev)
>  
>  static struct platform_driver mac_sonic_driver = {
>  	.probe  = mac_sonic_probe,
> -	.remove = __devexit_p(mac_sonic_device_remove),
> +	.remove = mac_sonic_device_remove,
>  	.driver	= {
>  		.name	= mac_sonic_string,
>  		.owner	= THIS_MODULE,
> diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
> index dbaaa99..119930b 100644
> --- a/drivers/net/ethernet/natsemi/natsemi.c
> +++ b/drivers/net/ethernet/natsemi/natsemi.c
> @@ -3353,7 +3353,7 @@ static struct pci_driver natsemi_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= natsemi_pci_tbl,
>  	.probe		= natsemi_probe1,
> -	.remove		= __devexit_p(natsemi_remove1),
> +	.remove		= natsemi_remove1,
>  #ifdef CONFIG_PM
>  	.suspend	= natsemi_suspend,
>  	.resume		= natsemi_resume,
> diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
> index d52728b..70ec426 100644
> --- a/drivers/net/ethernet/natsemi/ns83820.c
> +++ b/drivers/net/ethernet/natsemi/ns83820.c
> @@ -2272,7 +2272,7 @@ static struct pci_driver driver = {
>  	.name		= "ns83820",
>  	.id_table	= ns83820_pci_tbl,
>  	.probe		= ns83820_init_one,
> -	.remove		= __devexit_p(ns83820_remove_one),
> +	.remove		= ns83820_remove_one,
>  #if 0	/* FIXME: implement */
>  	.suspend	= ,
>  	.resume		= ,
> diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
> index 7dfe883..9bc1fc7 100644
> --- a/drivers/net/ethernet/natsemi/xtsonic.c
> +++ b/drivers/net/ethernet/natsemi/xtsonic.c
> @@ -314,7 +314,7 @@ static int __devexit xtsonic_device_remove (struct platform_device *pdev)
>  
>  static struct platform_driver xtsonic_driver = {
>  	.probe = xtsonic_probe,
> -	.remove = __devexit_p(xtsonic_device_remove),
> +	.remove = xtsonic_device_remove,
>  	.driver = {
>  		.name = xtsonic_string,
>  	},
> diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
> index c98decb..0c8742a 100644
> --- a/drivers/net/ethernet/neterion/s2io.c
> +++ b/drivers/net/ethernet/neterion/s2io.c
> @@ -494,7 +494,7 @@ static struct pci_driver s2io_driver = {
>  	.name = "S2IO",
>  	.id_table = s2io_tbl,
>  	.probe = s2io_init_nic,
> -	.remove = __devexit_p(s2io_rem_nic),
> +	.remove = s2io_rem_nic,
>  	.err_handler = &s2io_err_handler,
>  };
>  
> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> index 3e5b750..4af32a3 100644
> --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> @@ -4809,7 +4809,7 @@ static struct pci_driver vxge_driver = {
>  	.name = VXGE_DRIVER_NAME,
>  	.id_table = vxge_id_table,
>  	.probe = vxge_probe,
> -	.remove = __devexit_p(vxge_remove),
> +	.remove = vxge_remove,
>  #ifdef CONFIG_PM
>  	.suspend = vxge_pm_suspend,
>  	.resume = vxge_pm_resume,
> diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
> index 6893a65..fceec55 100644
> --- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
> +++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
> @@ -1096,7 +1096,7 @@ static int __devexit w90p910_ether_remove(struct platform_device *pdev)
>  
>  static struct platform_driver w90p910_ether_driver = {
>  	.probe		= w90p910_ether_probe,
> -	.remove		= __devexit_p(w90p910_ether_remove),
> +	.remove		= w90p910_ether_remove,
>  	.driver		= {
>  		.name	= "nuc900-emc",
>  		.owner	= THIS_MODULE,
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
> index 876bece..7f89407 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -6271,7 +6271,7 @@ static struct pci_driver driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= pci_tbl,
>  	.probe		= nv_probe,
> -	.remove		= __devexit_p(nv_remove),
> +	.remove		= nv_remove,
>  	.shutdown	= nv_shutdown,
>  	.driver.pm	= NV_PM_OPS,
>  };
> diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
> index af8b414..4638f6a 100644
> --- a/drivers/net/ethernet/nxp/lpc_eth.c
> +++ b/drivers/net/ethernet/nxp/lpc_eth.c
> @@ -1597,7 +1597,7 @@ MODULE_DEVICE_TABLE(of, lpc_eth_match);
>  
>  static struct platform_driver lpc_eth_driver = {
>  	.probe		= lpc_eth_drv_probe,
> -	.remove		= __devexit_p(lpc_eth_drv_remove),
> +	.remove		= lpc_eth_drv_remove,
>  #ifdef CONFIG_PM
>  	.suspend	= lpc_eth_drv_suspend,
>  	.resume		= lpc_eth_drv_resume,
> diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
> index f97719c..5fca4a2 100644
> --- a/drivers/net/ethernet/octeon/octeon_mgmt.c
> +++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
> @@ -1583,7 +1583,7 @@ static struct platform_driver octeon_mgmt_driver = {
>  		.of_match_table = octeon_mgmt_match,
>  	},
>  	.probe		= octeon_mgmt_probe,
> -	.remove		= __devexit_p(octeon_mgmt_remove),
> +	.remove		= octeon_mgmt_remove,
>  };
>  
>  extern void octeon_mdiobus_force_mod_depencency(void);
> diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
> index c236715..9664732 100644
> --- a/drivers/net/ethernet/packetengines/hamachi.c
> +++ b/drivers/net/ethernet/packetengines/hamachi.c
> @@ -1923,7 +1923,7 @@ static struct pci_driver hamachi_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= hamachi_pci_tbl,
>  	.probe		= hamachi_init_one,
> -	.remove		= __devexit_p(hamachi_remove_one),
> +	.remove		= hamachi_remove_one,
>  };
>  
>  static int __init hamachi_init (void)
> diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
> index 04e622f..aec57c0 100644
> --- a/drivers/net/ethernet/packetengines/yellowfin.c
> +++ b/drivers/net/ethernet/packetengines/yellowfin.c
> @@ -1399,7 +1399,7 @@ static struct pci_driver yellowfin_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= yellowfin_pci_tbl,
>  	.probe		= yellowfin_init_one,
> -	.remove		= __devexit_p(yellowfin_remove_one),
> +	.remove		= yellowfin_remove_one,
>  };
>  
>  
> diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
> index 6fa74d5..07943a3 100644
> --- a/drivers/net/ethernet/pasemi/pasemi_mac.c
> +++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
> @@ -1884,7 +1884,7 @@ static struct pci_driver pasemi_mac_driver = {
>  	.name		= "pasemi_mac",
>  	.id_table	= pasemi_mac_pci_tbl,
>  	.probe		= pasemi_mac_probe,
> -	.remove		= __devexit_p(pasemi_mac_remove),
> +	.remove		= pasemi_mac_remove,
>  };
>  
>  static void __exit pasemi_mac_cleanup_module(void)
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> index df45061..f0546b0 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
> @@ -3350,7 +3350,7 @@ static struct pci_driver netxen_driver = {
>  	.name = netxen_nic_driver_name,
>  	.id_table = netxen_pci_tbl,
>  	.probe = netxen_nic_probe,
> -	.remove = __devexit_p(netxen_nic_remove),
> +	.remove = netxen_nic_remove,
>  #ifdef CONFIG_PM
>  	.suspend = netxen_nic_suspend,
>  	.resume = netxen_nic_resume,
> diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
> index 12d1f24..506c72f 100644
> --- a/drivers/net/ethernet/qlogic/qla3xxx.c
> +++ b/drivers/net/ethernet/qlogic/qla3xxx.c
> @@ -3952,7 +3952,7 @@ static struct pci_driver ql3xxx_driver = {
>  	.name = DRV_NAME,
>  	.id_table = ql3xxx_pci_tbl,
>  	.probe = ql3xxx_probe,
> -	.remove = __devexit_p(ql3xxx_remove),
> +	.remove = ql3xxx_remove,
>  };
>  
>  module_pci_driver(ql3xxx_driver);
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 24ad17e..e553684 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -4533,7 +4533,7 @@ static struct pci_driver qlcnic_driver = {
>  	.name = qlcnic_driver_name,
>  	.id_table = qlcnic_pci_tbl,
>  	.probe = qlcnic_probe,
> -	.remove = __devexit_p(qlcnic_remove),
> +	.remove = qlcnic_remove,
>  #ifdef CONFIG_PM
>  	.suspend = qlcnic_suspend,
>  	.resume = qlcnic_resume,
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> index b262d61..a576a8d2 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> @@ -4921,7 +4921,7 @@ static struct pci_driver qlge_driver = {
>  	.name = DRV_NAME,
>  	.id_table = qlge_pci_tbl,
>  	.probe = qlge_probe,
> -	.remove = __devexit_p(qlge_remove),
> +	.remove = qlge_remove,
>  #ifdef CONFIG_PM
>  	.suspend = qlge_suspend,
>  	.resume = qlge_resume,
> diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
> index 557a265..4e91e18 100644
> --- a/drivers/net/ethernet/rdc/r6040.c
> +++ b/drivers/net/ethernet/rdc/r6040.c
> @@ -1274,7 +1274,7 @@ static struct pci_driver r6040_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= r6040_pci_tbl,
>  	.probe		= r6040_init_one,
> -	.remove		= __devexit_p(r6040_remove_one),
> +	.remove		= r6040_remove_one,
>  };
>  
>  module_pci_driver(r6040_driver);
> diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
> index 3ed7add..59d8d70 100644
> --- a/drivers/net/ethernet/realtek/8139too.c
> +++ b/drivers/net/ethernet/realtek/8139too.c
> @@ -2652,7 +2652,7 @@ static struct pci_driver rtl8139_pci_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= rtl8139_pci_tbl,
>  	.probe		= rtl8139_init_one,
> -	.remove		= __devexit_p(rtl8139_remove_one),
> +	.remove		= rtl8139_remove_one,
>  #ifdef CONFIG_PM
>  	.suspend	= rtl8139_suspend,
>  	.resume		= rtl8139_resume,
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 248f883..1a01b9f 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7028,7 +7028,7 @@ static struct pci_driver rtl8169_pci_driver = {
>  	.name		= MODULENAME,
>  	.id_table	= rtl8169_pci_tbl,
>  	.probe		= rtl_init_one,
> -	.remove		= __devexit_p(rtl_remove_one),
> +	.remove		= rtl_remove_one,
>  	.shutdown	= rtl_shutdown,
>  	.driver.pm	= RTL8169_PM_OPS,
>  };
> diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
> index 2ed3ab4..988e27d 100644
> --- a/drivers/net/ethernet/s6gmac.c
> +++ b/drivers/net/ethernet/s6gmac.c
> @@ -1046,7 +1046,7 @@ static int __devexit s6gmac_remove(struct platform_device *pdev)
>  
>  static struct platform_driver s6gmac_driver = {
>  	.probe = s6gmac_probe,
> -	.remove = __devexit_p(s6gmac_remove),
> +	.remove = s6gmac_remove,
>  	.driver = {
>  		.name = "s6gmac",
>  		.owner = THIS_MODULE,
> diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
> index 6a40dd0..0baae6a 100644
> --- a/drivers/net/ethernet/seeq/ether3.c
> +++ b/drivers/net/ethernet/seeq/ether3.c
> @@ -894,7 +894,7 @@ static const struct ecard_id ether3_ids[] = {
>  
>  static struct ecard_driver ether3_driver = {
>  	.probe		= ether3_probe,
> -	.remove		= __devexit_p(ether3_remove),
> +	.remove		= ether3_remove,
>  	.id_table	= ether3_ids,
>  	.drv = {
>  		.name	= "ether3",
> diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
> index 3e5519a..8d6546d 100644
> --- a/drivers/net/ethernet/sgi/ioc3-eth.c
> +++ b/drivers/net/ethernet/sgi/ioc3-eth.c
> @@ -1396,7 +1396,7 @@ static struct pci_driver ioc3_driver = {
>  	.name		= "ioc3-eth",
>  	.id_table	= ioc3_pci_tbl,
>  	.probe		= ioc3_probe,
> -	.remove		= __devexit_p(ioc3_remove_one),
> +	.remove		= ioc3_remove_one,
>  };
>  
>  static int __init ioc3_init_module(void)
> diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
> index 32e5566..a0a2e76 100644
> --- a/drivers/net/ethernet/silan/sc92031.c
> +++ b/drivers/net/ethernet/silan/sc92031.c
> @@ -1574,7 +1574,7 @@ static struct pci_driver sc92031_pci_driver = {
>  	.name		= SC92031_NAME,
>  	.id_table	= sc92031_pci_device_id_table,
>  	.probe		= sc92031_probe,
> -	.remove		= __devexit_p(sc92031_remove),
> +	.remove		= sc92031_remove,
>  	.suspend	= sc92031_suspend,
>  	.resume		= sc92031_resume,
>  };
> diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
> index d816601..67fbd4a 100644
> --- a/drivers/net/ethernet/sis/sis190.c
> +++ b/drivers/net/ethernet/sis/sis190.c
> @@ -1932,7 +1932,7 @@ static struct pci_driver sis190_pci_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= sis190_pci_tbl,
>  	.probe		= sis190_init_one,
> -	.remove		= __devexit_p(sis190_remove_one),
> +	.remove		= sis190_remove_one,
>  };
>  
>  static int __init sis190_init_module(void)
> diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
> index fb9f6b3..d068e2b 100644
> --- a/drivers/net/ethernet/sis/sis900.c
> +++ b/drivers/net/ethernet/sis/sis900.c
> @@ -2496,7 +2496,7 @@ static struct pci_driver sis900_pci_driver = {
>  	.name		= SIS900_MODULE_NAME,
>  	.id_table	= sis900_pci_tbl,
>  	.probe		= sis900_probe,
> -	.remove		= __devexit_p(sis900_remove),
> +	.remove		= sis900_remove,
>  #ifdef CONFIG_PM
>  	.suspend	= sis900_suspend,
>  	.resume		= sis900_resume,
> diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
> index d01e59c..67e694b 100644
> --- a/drivers/net/ethernet/smsc/epic100.c
> +++ b/drivers/net/ethernet/smsc/epic100.c
> @@ -1577,7 +1577,7 @@ static struct pci_driver epic_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= epic_pci_tbl,
>  	.probe		= epic_init_one,
> -	.remove		= __devexit_p(epic_remove_one),
> +	.remove		= epic_remove_one,
>  #ifdef CONFIG_PM
>  	.suspend	= epic_suspend,
>  	.resume		= epic_resume,
> diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
> index 8d15f7a..f19fba7 100644
> --- a/drivers/net/ethernet/smsc/smc911x.c
> +++ b/drivers/net/ethernet/smsc/smc911x.c
> @@ -2186,7 +2186,7 @@ static int smc911x_drv_resume(struct platform_device *dev)
>  
>  static struct platform_driver smc911x_driver = {
>  	.probe		 = smc911x_drv_probe,
> -	.remove	 = __devexit_p(smc911x_drv_remove),
> +	.remove	 = smc911x_drv_remove,
>  	.suspend	 = smc911x_drv_suspend,
>  	.resume	 = smc911x_drv_resume,
>  	.driver	 = {
> diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
> index 318adc9..8d85cbd 100644
> --- a/drivers/net/ethernet/smsc/smc91x.c
> +++ b/drivers/net/ethernet/smsc/smc91x.c
> @@ -2407,7 +2407,7 @@ static struct dev_pm_ops smc_drv_pm_ops = {
>  
>  static struct platform_driver smc_driver = {
>  	.probe		= smc_drv_probe,
> -	.remove		= __devexit_p(smc_drv_remove),
> +	.remove		= smc_drv_remove,
>  	.driver		= {
>  		.name	= CARDNAME,
>  		.owner	= THIS_MODULE,
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 62d1baf..7d034fc 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -2576,7 +2576,7 @@ MODULE_DEVICE_TABLE(of, smsc911x_dt_ids);
>  
>  static struct platform_driver smsc911x_driver = {
>  	.probe = smsc911x_drv_probe,
> -	.remove = __devexit_p(smsc911x_drv_remove),
> +	.remove = smsc911x_drv_remove,
>  	.driver = {
>  		.name	= SMSC_CHIPNAME,
>  		.owner	= THIS_MODULE,
> diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
> index 1fcd914e..ed96967 100644
> --- a/drivers/net/ethernet/smsc/smsc9420.c
> +++ b/drivers/net/ethernet/smsc/smsc9420.c
> @@ -1736,7 +1736,7 @@ static struct pci_driver smsc9420_driver = {
>  	.name = DRV_NAME,
>  	.id_table = smsc9420_id_table,
>  	.probe = smsc9420_probe,
> -	.remove = __devexit_p(smsc9420_remove),
> +	.remove = smsc9420_remove,
>  #ifdef CONFIG_PM
>  	.suspend = smsc9420_suspend,
>  	.resume = smsc9420_resume,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index 1f069b0..743ab67 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -182,7 +182,7 @@ struct pci_driver stmmac_pci_driver = {
>  	.name = STMMAC_RESOURCE_NAME,
>  	.id_table = stmmac_id_table,
>  	.probe = stmmac_pci_probe,
> -	.remove = __devexit_p(stmmac_pci_remove),
> +	.remove = stmmac_pci_remove,
>  #ifdef CONFIG_PM
>  	.suspend = stmmac_pci_suspend,
>  	.resume = stmmac_pci_resume,
> diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
> index c8251be..9d716c6 100644
> --- a/drivers/net/ethernet/sun/cassini.c
> +++ b/drivers/net/ethernet/sun/cassini.c
> @@ -5273,7 +5273,7 @@ static struct pci_driver cas_driver = {
>  	.name		= DRV_MODULE_NAME,
>  	.id_table	= cas_pci_tbl,
>  	.probe		= cas_init_one,
> -	.remove		= __devexit_p(cas_remove_one),
> +	.remove		= cas_remove_one,
>  #ifdef CONFIG_PM
>  	.suspend	= cas_suspend,
>  	.resume		= cas_resume
> diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
> index 275b430..94b0085 100644
> --- a/drivers/net/ethernet/sun/niu.c
> +++ b/drivers/net/ethernet/sun/niu.c
> @@ -9980,7 +9980,7 @@ static struct pci_driver niu_pci_driver = {
>  	.name		= DRV_MODULE_NAME,
>  	.id_table	= niu_pci_tbl,
>  	.probe		= niu_pci_init_one,
> -	.remove		= __devexit_p(niu_pci_remove_one),
> +	.remove		= niu_pci_remove_one,
>  	.suspend	= niu_suspend,
>  	.resume		= niu_resume,
>  };
> @@ -10211,7 +10211,7 @@ static struct platform_driver niu_of_driver = {
>  		.of_match_table = niu_match,
>  	},
>  	.probe		= niu_of_probe,
> -	.remove		= __devexit_p(niu_of_remove),
> +	.remove		= niu_of_remove,
>  };
>  
>  #endif /* CONFIG_SPARC64 */
> diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
> index c9c977b..41609b8 100644
> --- a/drivers/net/ethernet/sun/sunbmac.c
> +++ b/drivers/net/ethernet/sun/sunbmac.c
> @@ -1286,7 +1286,7 @@ static struct platform_driver bigmac_sbus_driver = {
>  		.of_match_table = bigmac_sbus_match,
>  	},
>  	.probe		= bigmac_sbus_probe,
> -	.remove		= __devexit_p(bigmac_sbus_remove),
> +	.remove		= bigmac_sbus_remove,
>  };
>  
>  module_platform_driver(bigmac_sbus_driver);
> diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
> index 73f341b..61147c2 100644
> --- a/drivers/net/ethernet/sun/sunhme.c
> +++ b/drivers/net/ethernet/sun/sunhme.c
> @@ -3190,7 +3190,7 @@ static struct pci_driver hme_pci_driver = {
>  	.name		= "hme",
>  	.id_table	= happymeal_pci_ids,
>  	.probe		= happy_meal_pci_probe,
> -	.remove		= __devexit_p(happy_meal_pci_remove),
> +	.remove		= happy_meal_pci_remove,
>  };
>  
>  static int __init happy_meal_pci_init(void)
> @@ -3284,7 +3284,7 @@ static struct platform_driver hme_sbus_driver = {
>  		.of_match_table = hme_sbus_match,
>  	},
>  	.probe		= hme_sbus_probe,
> -	.remove		= __devexit_p(hme_sbus_remove),
> +	.remove		= hme_sbus_remove,
>  };
>  
>  static int __init happy_meal_sbus_init(void)
> diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
> index aeded7f..10b0f50 100644
> --- a/drivers/net/ethernet/sun/sunqe.c
> +++ b/drivers/net/ethernet/sun/sunqe.c
> @@ -971,7 +971,7 @@ static struct platform_driver qec_sbus_driver = {
>  		.of_match_table = qec_sbus_match,
>  	},
>  	.probe		= qec_sbus_probe,
> -	.remove		= __devexit_p(qec_sbus_remove),
> +	.remove		= qec_sbus_remove,
>  };
>  
>  static int __init qec_init(void)
> diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
> index 6ce9edd..5f6d1f0 100644
> --- a/drivers/net/ethernet/tehuti/tehuti.c
> +++ b/drivers/net/ethernet/tehuti/tehuti.c
> @@ -2458,7 +2458,7 @@ static struct pci_driver bdx_pci_driver = {
>  	.name = BDX_DRV_NAME,
>  	.id_table = bdx_pci_tbl,
>  	.probe = bdx_probe,
> -	.remove = __devexit_p(bdx_remove),
> +	.remove = bdx_remove,
>  };
>  
>  /*
> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
> index 860c252..723cba0 100644
> --- a/drivers/net/ethernet/ti/cpmac.c
> +++ b/drivers/net/ethernet/ti/cpmac.c
> @@ -1216,7 +1216,7 @@ static struct platform_driver cpmac_driver = {
>  	.driver.name = "cpmac",
>  	.driver.owner = THIS_MODULE,
>  	.probe = cpmac_probe,
> -	.remove = __devexit_p(cpmac_remove),
> +	.remove = cpmac_remove,
>  };
>  
>  int __devinit cpmac_init(void)
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 7654a62..64ea9a9 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1492,7 +1492,7 @@ static struct platform_driver cpsw_driver = {
>  		.of_match_table = of_match_ptr(cpsw_of_mtable),
>  	},
>  	.probe = cpsw_probe,
> -	.remove = __devexit_p(cpsw_remove),
> +	.remove = cpsw_remove,
>  };
>  
>  static int __init cpsw_init(void)
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index fce89a0a..e6cbedc 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -2107,7 +2107,7 @@ static struct platform_driver davinci_emac_driver = {
>  		.of_match_table = of_match_ptr(davinci_emac_of_match),
>  	},
>  	.probe = davinci_emac_probe,
> -	.remove = __devexit_p(davinci_emac_remove),
> +	.remove = davinci_emac_remove,
>  };
>  
>  /**
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 51a96db..ca69af8 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -496,7 +496,7 @@ static struct platform_driver davinci_mdio_driver = {
>  		.of_match_table = of_match_ptr(davinci_mdio_of_mtable),
>  	},
>  	.probe = davinci_mdio_probe,
> -	.remove = __devexit_p(davinci_mdio_remove),
> +	.remove = davinci_mdio_remove,
>  };
>  
>  static int __init davinci_mdio_init(void)
> diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
> index 3e6abf0f..9e326b2 100644
> --- a/drivers/net/ethernet/ti/tlan.c
> +++ b/drivers/net/ethernet/ti/tlan.c
> @@ -392,7 +392,7 @@ static struct pci_driver tlan_driver = {
>  	.name		= "tlan",
>  	.id_table	= tlan_pci_tbl,
>  	.probe		= tlan_init_one,
> -	.remove		= __devexit_p(tlan_remove_one),
> +	.remove		= tlan_remove_one,
>  	.suspend	= tlan_suspend,
>  	.resume		= tlan_resume,
>  };
> diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
> index c1ebfe9..a89279f 100644
> --- a/drivers/net/ethernet/toshiba/spider_net.c
> +++ b/drivers/net/ethernet/toshiba/spider_net.c
> @@ -2559,7 +2559,7 @@ static struct pci_driver spider_net_driver = {
>  	.name		= spider_net_driver_name,
>  	.id_table	= spider_net_pci_tbl,
>  	.probe		= spider_net_probe,
> -	.remove		= __devexit_p(spider_net_remove)
> +	.remove		= spider_net_remove
>  };
>  
>  /**
> diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
> index 651a70c..6d6af5d 100644
> --- a/drivers/net/ethernet/toshiba/tc35815.c
> +++ b/drivers/net/ethernet/toshiba/tc35815.c
> @@ -2198,7 +2198,7 @@ static struct pci_driver tc35815_pci_driver = {
>  	.name		= MODNAME,
>  	.id_table	= tc35815_pci_tbl,
>  	.probe		= tc35815_init_one,
> -	.remove		= __devexit_p(tc35815_remove_one),
> +	.remove		= tc35815_remove_one,
>  #ifdef CONFIG_PM
>  	.suspend	= tc35815_suspend,
>  	.resume		= tc35815_resume,
> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
> index 0459c09..565f077 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -2359,7 +2359,7 @@ static struct pci_driver rhine_driver = {
>  	.name		= DRV_NAME,
>  	.id_table	= rhine_pci_tbl,
>  	.probe		= rhine_init_one,
> -	.remove		= __devexit_p(rhine_remove_one),
> +	.remove		= rhine_remove_one,
>  	.shutdown	= rhine_shutdown,
>  	.driver.pm	= RHINE_PM_OPS,
>  };
> diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
> index a46c198..44e2fa4 100644
> --- a/drivers/net/ethernet/via/via-velocity.c
> +++ b/drivers/net/ethernet/via/via-velocity.c
> @@ -3108,7 +3108,7 @@ static struct pci_driver velocity_driver = {
>  	.name		= VELOCITY_NAME,
>  	.id_table	= velocity_id_table,
>  	.probe		= velocity_found1,
> -	.remove		= __devexit_p(velocity_remove1),
> +	.remove		= velocity_remove1,
>  #ifdef CONFIG_PM
>  	.suspend	= velocity_suspend,
>  	.resume		= velocity_resume,
> diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
> index 2c08bf6..82187f3 100644
> --- a/drivers/net/ethernet/wiznet/w5100.c
> +++ b/drivers/net/ethernet/wiznet/w5100.c
> @@ -801,7 +801,7 @@ static struct platform_driver w5100_driver = {
>  		.pm	= &w5100_pm_ops,
>  	},
>  	.probe		= w5100_probe,
> -	.remove		= __devexit_p(w5100_remove),
> +	.remove		= w5100_remove,
>  };
>  
>  module_platform_driver(w5100_driver);
> diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
> index 88943d9..48c182e 100644
> --- a/drivers/net/ethernet/wiznet/w5300.c
> +++ b/drivers/net/ethernet/wiznet/w5300.c
> @@ -713,7 +713,7 @@ static struct platform_driver w5300_driver = {
>  		.pm	= &w5300_pm_ops,
>  	},
>  	.probe		= w5300_probe,
> -	.remove		= __devexit_p(w5300_remove),
> +	.remove		= w5300_remove,
>  };
>  
>  module_platform_driver(w5300_driver);
> diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
> index f8e3518..6ac9e4c 100644
> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
> @@ -1174,7 +1174,7 @@ MODULE_DEVICE_TABLE(of, temac_of_match);
>  
>  static struct platform_driver temac_of_driver = {
>  	.probe = temac_of_probe,
> -	.remove = __devexit_p(temac_of_remove),
> +	.remove = temac_of_remove,
>  	.driver = {
>  		.owner = THIS_MODULE,
>  		.name = "xilinx_temac",
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> index 1d04754..6020244 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -1654,7 +1654,7 @@ static int __devexit axienet_of_remove(struct platform_device *op)
>  
>  static struct platform_driver axienet_of_driver = {
>  	.probe = axienet_of_probe,
> -	.remove = __devexit_p(axienet_of_remove),
> +	.remove = axienet_of_remove,
>  	.driver = {
>  		 .owner = THIS_MODULE,
>  		 .name = "xilinx_axienet",
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> index 77cfe51..c4d7a80 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -1298,7 +1298,7 @@ static struct platform_driver xemaclite_of_driver = {
>  		.of_match_table = xemaclite_of_match,
>  	},
>  	.probe		= xemaclite_of_probe,
> -	.remove		= __devexit_p(xemaclite_of_remove),
> +	.remove		= xemaclite_of_remove,
>  };
>  
>  module_platform_driver(xemaclite_of_driver);
> 


-- 
Nicolas Ferre
