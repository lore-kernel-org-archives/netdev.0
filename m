From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] Fix a typo in PTP_1588_CLOCK_PCH Kconfig help info.
Date: Thu, 27 Sep 2012 18:06:40 -0400 (EDT)
Message-ID: <20120927.180640.447002776076460117.davem@davemloft.net>
References: <506009A4.8000202@linux.intel.com>
	<50600A49.7040902@linux.intel.com>
	<5060F9C4.4050303@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tshimizu818@gmail.com,
	linux-kernel@vger.kernel.org, haicheng.lee@gmail.com
To: haicheng.li@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5060F9C4.4050303@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haicheng Li <haicheng.li@linux.intel.com>
Date: Tue, 25 Sep 2012 08:24:36 +0800

> From 5911413366d37aafcc19ddfc9c0f2db31855431e Mon Sep 17 00:00:00 2001
> From: Haicheng Li <haicheng.li@linux.intel.com>
> Date: Mon, 24 Sep 2012 15:55:27 +0800
> Subject: [PATCH 2/2] Fix a typo in PTP_1588_CLOCK_PCH Kconfig help
> info.
> 
> Signed-off-by: Haicheng Li <haicheng.lee@gmail.com>
> ---
>  drivers/ptp/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
> index ffdf712..82c4a26 100644
> --- a/drivers/ptp/Kconfig
> +++ b/drivers/ptp/Kconfig
> @@ -87,6 +87,6 @@ config PTP_1588_CLOCK_PCH
>  	  SO_TIMESTAMPING API.
> 
>  	  To compile this driver as a module, choose M here: the module
> -	  will be called ptp_pch.
> +	  will be called by pch_ptp.

The original sentence is correct, it is stating the name of the module
that will be built not the module that will call it.

Rather, the "pch_ptp" is what might need to be adjusted.
