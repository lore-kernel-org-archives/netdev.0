From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [PATCH 14/25] drivers/net/vnxnet3: Use static
 const	char arrays
Date: Mon, 13 Sep 2010 12:50:27 -0700
Message-ID: <8B1F619C9F5F454E81D90D3C161698D70337BB4D4D@EXCH-MBX-3.vmware.com>
References: <cover.1284406638.git.joe@perches.com>
 <a2e0d6f77c221ebf7f642dd02da85bcd41947242.1284406638.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "VMware, Inc." <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a2e0d6f77c221ebf7f642dd02da85bcd41947242.1284406638.git.joe@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks.

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>

> -----Original Message-----
> From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-
> bounces@vmware.com] On Behalf Of Joe Perches
> Sent: Monday, September 13, 2010 12:48 PM
> To: linux-kernel@vger.kernel.org
> Cc: VMware, Inc.; netdev@vger.kernel.org
> Subject: [Pv-drivers] [PATCH 14/25] drivers/net/vnxnet3: Use static
> const char arrays
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
>  drivers/net/vmxnet3/vmxnet3_int.h |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 198ce92..dfc0014 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -28,7 +28,7 @@
> 
>  #include "vmxnet3_int.h"
> 
> -char vmxnet3_driver_name[] = "vmxnet3";
> +const char vmxnet3_driver_name[] = "vmxnet3";
>  #define VMXNET3_DRIVER_DESC "VMware vmxnet3 virtual NIC driver"
> 
>  /*
> diff --git a/drivers/net/vmxnet3/vmxnet3_int.h
> b/drivers/net/vmxnet3/vmxnet3_int.h
> index 2121c73..201fcf7 100644
> --- a/drivers/net/vmxnet3/vmxnet3_int.h
> +++ b/drivers/net/vmxnet3/vmxnet3_int.h
> @@ -384,5 +384,5 @@ vmxnet3_create_queues(struct vmxnet3_adapter
> *adapter,
>  extern void vmxnet3_set_ethtool_ops(struct net_device *netdev);
>  extern struct net_device_stats *vmxnet3_get_stats(struct net_device
> *netdev);
> 
> -extern char vmxnet3_driver_name[];
> +extern const char vmxnet3_driver_name[];
>  #endif
> --
> 1.7.3.rc1
> 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
