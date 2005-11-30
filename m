From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Add MIPS dependency for dm9000 driver
Date: Wed, 30 Nov 2005 13:27:57 -0800
Message-ID: <20051130132757.36e1cca0.akpm@osdl.org>
References: <cda58cb80511300918i7df1c60au@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750820AbVK3V0n@vger.kernel.org>
To: Franck <vagabon.xyz@gmail.com>
In-Reply-To: <cda58cb80511300918i7df1c60au@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Franck <vagabon.xyz@gmail.com> wrote:
>
> The attached patch adds MIPS dependency for dm9000 ethernet
> controller. Indeed this controller is used by some embedded platforms
> based on MIPS CPUs.
> 
> Signed-Off-By: Franck Bui-Huu <franck.bui@gmail.com>
> ---
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f15f909..1b00169 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -856,7 +856,7 @@ config SMC9194
> 
>  config DM9000
>  	tristate "DM9000 support"
> -	depends on ARM && NET_ETHERNET
> +	depends on (ARM || MIPS) && NET_ETHERNET
>  	select CRC32
>  	select MII

Is there any reason why we cannot enable this driver on all architectures?

It's moderately important for quality and maintainability reasons that it
be included in the x86 build, at least..
