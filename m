From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 06:59:24 +0200
Message-ID: <543DFF2C.40306@hartkopp.net>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LeoLi@freescale.com,
	linux-doc@vger.kernel.org
To: Pan Jiafei <Jiafei.Pan@freescale.com>, davem@davemloft.net,
	jkosina@suse.cz
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.10.2014 05:26, Pan Jiafei wrote:
> In some platform, there are some hardware block provided
> to manage buffers to improve performance.

(..)

> diff --git a/net/Kconfig b/net/Kconfig
> index d6b138e..346e021 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -291,6 +291,16 @@ config NET_FLOW_LIMIT
>   	  with many clients some protection against DoS by a single (spoofed)
>   	  flow that greatly exceeds average workload.
>
> +config USE_HW_SKB
> +	bool "NIC use hardware managed buffer to build skb"
> +	depends on INET

The feature seems to be valid for network devices in general.
Why did you make it depending on INET ??

Regards,
Oliver

> +	---help---
> +	  If select this, the third party drivers will use hardware managed
> +	  buffers to allocate SKB without any modification for the driver.
> +
> +	  Documentation on how to use this featue can be found at
> +	  <file:Documentation/networking/hw_skb.txt>.
> +
>   menu "Network testing"
>
>   config NET_PKTGEN

