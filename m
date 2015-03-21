From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: make NET_DSA manually selectable from the
 config
Date: Sat, 21 Mar 2015 16:21:03 +0100
Message-ID: <20150321152103.GB11720@lunn.ch>
References: <1426901463-31913-1-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com, linux@roeck-us.net,
	jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426901463-31913-1-git-send-email-mathieu@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 20, 2015 at 06:31:03PM -0700, Mathieu Olivari wrote:
> Change bd76a116707bd2381da36cf7c3183df11293f1d6 made all DSA drivers
> depend on NET_DSA rather than selecting them. However, as the only way
> to select this option was to actually select a driver, it made DSA
> impossible to enable at all.
> 
> This patch adds an explicit entry which the user will have to enable
> prior selecting a driver.
> 
> Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>

A bit late, but

Review-by: Andrew Lunn <andrew@lunn.ch>

	   Andrew

> ---
>  net/dsa/Kconfig | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index 087e654..4f3cce1 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -5,9 +5,12 @@ config HAVE_NET_DSA
>  # Drivers must select NET_DSA and the appropriate tagging format
>  
>  config NET_DSA
> -	tristate
> +	tristate "Distributed Switch Architecture"
>  	depends on HAVE_NET_DSA && NET_SWITCHDEV
>  	select PHYLIB
> +	---help---
> +	  Say Y if you want to enable support for the hardware switches supported
> +	  by the Distributed Switch Architecture.
>  
>  if NET_DSA
>  
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
