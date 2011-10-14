From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] staging: hv: move hv_netvsc out of staging area
Date: Fri, 14 Oct 2011 21:35:50 +0200
Message-ID: <1318620950.31522.9.camel@lappy>
References: <1318620026-8349-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	Mike Sterling <Mike.Sterling@microsoft.com>, devel@linuxdriverproject.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1318620026-8349-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-10-14 at 12:20 -0700, Haiyang Zhang wrote:
> hv_netvsc has been reviewed on netdev mailing list on 6/09/2011.
> All recommended changes have been made. We are requesting to move
> it out of staging area.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: KY Srinivasan <kys@microsoft.com>
> Signed-off-by: Mike Sterling <Mike.Sterling@microsoft.com>
> Cc: NetDev <netdev@vger.kernel.org>
> 
> ---
>  drivers/net/Kconfig                               |    2 ++
>  drivers/net/Makefile                              |    2 ++
>  drivers/net/hyperv/Kconfig                        |    5 +++++
>  drivers/net/hyperv/Makefile                       |    3 +++
>  drivers/{staging/hv => net/hyperv}/hyperv_net.h   |    0
>  drivers/{staging/hv => net/hyperv}/netvsc.c       |    0
>  drivers/{staging/hv => net/hyperv}/netvsc_drv.c   |    0
>  drivers/{staging/hv => net/hyperv}/rndis_filter.c |    0
>  drivers/staging/hv/Kconfig                        |    6 ------
>  drivers/staging/hv/Makefile                       |    2 --
>  drivers/staging/hv/TODO                           |    1 -
>  11 files changed, 12 insertions(+), 9 deletions(-)
>  create mode 100644 drivers/net/hyperv/Kconfig
>  create mode 100644 drivers/net/hyperv/Makefile
>  rename drivers/{staging/hv => net/hyperv}/hyperv_net.h (100%)
>  rename drivers/{staging/hv => net/hyperv}/netvsc.c (100%)
>  rename drivers/{staging/hv => net/hyperv}/netvsc_drv.c (100%)
>  rename drivers/{staging/hv => net/hyperv}/rndis_filter.c (100%)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 8d0314d..088c330 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -3451,4 +3451,6 @@ config VMXNET3
>  	  To compile this driver as a module, choose M here: the
>  	  module will be called vmxnet3.
>  
> +source "drivers/net/hyperv/Kconfig"
> +
>  endif # NETDEVICES
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index e1eca2a..647c878 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -306,3 +306,5 @@ obj-$(CONFIG_CAIF) += caif/
>  obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
>  obj-$(CONFIG_PCH_GBE) += pch_gbe/
>  obj-$(CONFIG_TILE_NET) += tile/
> +
> +obj-$(CONFIG_HYPERV_NET) += hyperv/
> diff --git a/drivers/net/hyperv/Kconfig b/drivers/net/hyperv/Kconfig
> new file mode 100644
> index 0000000..936968d
> --- /dev/null
> +++ b/drivers/net/hyperv/Kconfig
> @@ -0,0 +1,5 @@
> +config HYPERV_NET
> +	tristate "Microsoft Hyper-V virtual network driver"
> +	depends on HYPERV

It doesn't depend on NET anymore?

-- 

Sasha.
