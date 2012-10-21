From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 2/5] net/at91_ether: select MACB in Kconfig
Date: Sun, 21 Oct 2012 20:31:22 +0200
Message-ID: <20121021183122.GB18964@game.jcrosoft.org>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
 <1350829392-3812-3-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bgat@billgatliff.com, netdev@vger.kernel.org, nicolas.ferre@atmel.com,
 hskinnemoen@gmail.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, egtvedt@samfundet.no
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1350829392-3812-3-git-send-email-manabian@gmail.com>
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

On 16:23 Sun 21 Oct     , Joachim Eastwood wrote:
> Now that HAVE_NET_MACB is gone let's just select MACB to
> satisfy the dependecies in at91_ether.
> 
> PHYLIB will then by selected by MACB.
> 
> Signed-off-by: Joachim Eastwood <manabian@gmail.com>
> ---
>  drivers/net/ethernet/cadence/Kconfig  | 2 +-
>  drivers/net/ethernet/cadence/Makefile | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
> index 5d1ea30..f6d0956 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -23,7 +23,7 @@ config ARM_AT91_ETHER
>  	tristate "AT91RM9200 Ethernet support"
>  	depends on ARM && ARCH_AT91RM9200
>  	select NET_CORE
> -	select PHYLIB
> +	select MACB
no the ether and macb are two diferrent drivers for 2 IPs from cadence

the ehter does not need the macb

Best Regards,
J.
>  	---help---
>  	  If you wish to compile a kernel for the AT91RM9200 and enable
>  	  ethernet support, then you should always answer Y to this.
> diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
> index 798b1e0..9068b83 100644
> --- a/drivers/net/ethernet/cadence/Makefile
> +++ b/drivers/net/ethernet/cadence/Makefile
> @@ -2,5 +2,5 @@
>  # Makefile for the Atmel network device drivers.
>  #
>  
> -obj-$(CONFIG_ARM_AT91_ETHER) += at91_ether.o macb.o
> +obj-$(CONFIG_ARM_AT91_ETHER) += at91_ether.o
>  obj-$(CONFIG_MACB) += macb.o
> -- 
> 1.7.12.4
> 
