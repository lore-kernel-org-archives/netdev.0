From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] staging: hv: move hv_netvsc into drivers/net directory
Date: Thu, 3 Nov 2011 16:30:55 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0CC98B5B@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1318624485-23865-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@suse.de" <gregkh@suse.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Haiyang Zhang" <haiyangz@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	"Mike Sterling" <Mike.Sterling@microsoft.com>
To: NetDev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"virtualization@lists.os
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318624485-23865-1-git-send-email-haiyangz@microsoft.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Haiyang Zhang [mailto:haiyangz@microsoft.com]
> Sent: Friday, October 14, 2011 4:35 PM
> To: Haiyang Zhang; KY Srinivasan; gregkh@suse.de; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org;
> virtualization@lists.osdl.org
> Cc: Mike Sterling; NetDev
> Subject: [PATCH] staging: hv: move hv_netvsc into drivers/net
> directory
> 
> hv_netvsc has been reviewed on netdev mailing list on 6/09/2011.
> All recommended changes have been made. We are requesting to move
> it from staging area into drivers/net directory.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: KY Srinivasan <kys@microsoft.com>
> Signed-off-by: Mike Sterling <Mike.Sterling@microsoft.com>
> Cc: NetDev <netdev@vger.kernel.org>
> 
> ---
>  drivers/net/Kconfig               |    2 +
>  drivers/net/Makefile              |    2 +
>  drivers/net/hyperv/Kconfig        |    5 +
>  drivers/net/hyperv/Makefile       |    3 +
>  drivers/net/hyperv/hyperv_net.h   | 1058
> +++++++++++++++++++++++++++++++++++++
>  drivers/net/hyperv/netvsc.c       |  944
> +++++++++++++++++++++++++++++++++
>  drivers/net/hyperv/netvsc_drv.c   |  456 ++++++++++++++++
>  drivers/net/hyperv/rndis_filter.c |  855
> ++++++++++++++++++++++++++++++
>  8 files changed, 3325 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/hyperv/Kconfig
>  create mode 100644 drivers/net/hyperv/Makefile
>  create mode 100644 drivers/net/hyperv/hyperv_net.h
>  create mode 100644 drivers/net/hyperv/netvsc.c
>  create mode 100644 drivers/net/hyperv/netvsc_drv.c
>  create mode 100644 drivers/net/hyperv/rndis_filter.c
> 

Hi Dave,

Do you have any comments on this patch which requesting hv_netvsc
out of staging area?

Thanks,
- Haiyang
