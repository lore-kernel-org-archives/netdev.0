From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: Standardize prefixes for message
 logging
Date: Mon, 12 Mar 2012 17:05:58 -0700 (PDT)
Message-ID: <20120312.170558.584205292599435892.davem@davemloft.net>
References: <1331526971.13200.9.camel@joe2Laptop>
	<20120311.234846.455580505379366792.davem@davemloft.net>
	<1331571812.13200.23.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331571812.13200.23.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 12 Mar 2012 10:03:32 -0700

> Add #define pr_fmt(fmt) as appropriate.
> 
> Add "IPv4: ", "TCP: ", and "IPsec: " to appropriate files.
> Standardize on "UDPLite: " for appropriate uses.
> Some prefixes were previously "UDPLITE: " and "UDP-Lite: ".
> 
> Add KBUILD_MODNAME ": " to icmp and gre.
> Remove embedded prefixes as appropriate.
> 
> Add missing "\n" to pr_info in gre.c.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Looks good, and applied, but I left out this hunk:

> diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
> index 63b64c4..56d6768 100644
> --- a/net/ipv4/ipcomp.c
> +++ b/net/ipv4/ipcomp.c
> @@ -13,6 +13,7 @@
>   *   - Compression stats.
>   *   - Adaptive compression.
>   */
> +
>  #include <linux/module.h>
>  #include <linux/err.h>
>  #include <linux/rtnetlink.h>

As it seemed accidental, if not gratuitous.
