From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 1/1] net: add micrel KSZ8873MLL switch support
Date: Wed, 21 Nov 2012 12:40:14 +0200
Message-ID: <20121121104014.GC28785@sapphire.tkos.co.il>
References: <1353493630-30867-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1353493630-30867-1-git-send-email-plagnioj@jcrosoft.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Jean-Christophe,

On Wed, Nov 21, 2012 at 11:27:10AM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> this will allow to detect the link between the switch and the soc
> 
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> Cc: netdev@vger.kernel.org

[...]

> @@ -204,6 +237,16 @@ static struct phy_driver ksphy_driver[] = {
>  	.ack_interrupt	= kszphy_ack_interrupt,
>  	.config_intr	= ksz9021_config_intr,
>  	.driver		= { .owner = THIS_MODULE, },
> +}, {
> +	.phy_id		= PHY_ID_KSZ8873MLL,
> +	.phy_id_mask	= 0x00fffff0,
> +	.name		= "Micrel KSZ8873MLL Swithch",

s/Swithch/Switch/

> +	.features	= (SUPPORTED_Pause | SUPPORTED_Asym_Pause),
> +	.flags		= PHY_HAS_MAGICANEG,
> +	.config_init	= kszphy_config_init,
> +	.config_aneg	= ksz8873mll_config_aneg,
> +	.read_status	= ksz8873mll_read_status,
> +	.driver		= { .owner = THIS_MODULE, },
>  } };
>  
>  static int __init ksphy_init(void)

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
