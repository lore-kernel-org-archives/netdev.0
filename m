From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [2.6 patch] drivers/char/random.c: unexport
 secure_ipv6_port_ephemeral
Date: Wed, 5 Apr 2006 10:11:11 -0700
Message-ID: <20060405101111.0edc161a@localhost.localdomain>
References: <20060405163610.GG8673@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751300AbWDEROZ@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060405163610.GG8673@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 5 Apr 2006 18:36:10 +0200
Adrian Bunk <bunk@stusta.de> wrote:

> This patch removes the unused EXPORT_SYMBOL(secure_ipv6_port_ephemeral).
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> --- linux-2.6.17-rc1-mm1-full/drivers/char/random.c.old	2006-04-05 17:00:04.000000000 +0200
> +++ linux-2.6.17-rc1-mm1-full/drivers/char/random.c	2006-04-05 17:00:22.000000000 +0200
> @@ -1584,7 +1584,6 @@
>  
>  	return twothirdsMD4Transform(daddr, hash);
>  }
> -EXPORT_SYMBOL(secure_ipv6_port_ephemeral);
>  #endif
>  
>  #if defined(CONFIG_IP_DCCP) || defined(CONFIG_IP_DCCP_MODULE)
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

NAK

If IPV6 is built as a module, then it is needed.
