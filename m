From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: dsa: make NET_DSA manually selectable from the config
Date: Fri, 20 Mar 2015 18:37:43 -0700
Message-ID: <550CCB67.5010008@roeck-us.net>
References: <1426901463-31913-1-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Mathieu Olivari <mathieu@codeaurora.org>, davem@davemloft.net,
	f.fainelli@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426901463-31913-1-git-send-email-mathieu@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/2015 06:31 PM, Mathieu Olivari wrote:
> Change bd76a116707bd2381da36cf7c3183df11293f1d6 made all DSA drivers
> depend on NET_DSA rather than selecting them. However, as the only way
> to select this option was to actually select a driver, it made DSA
> impossible to enable at all.
>
> This patch adds an explicit entry which the user will have to enable
> prior selecting a driver.
>

Fixes: bd76a116707b ("dsa: change "select" to "depends on" for NET_SWITCHDEV and for NET_DSA")

> Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>

Andrew found the same problem yesterday and was about to submit
the same patch...

Reviewed-by: Guenter Roeck <linux@roeck-us.net>

> ---
>   net/dsa/Kconfig | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index 087e654..4f3cce1 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -5,9 +5,12 @@ config HAVE_NET_DSA
>   # Drivers must select NET_DSA and the appropriate tagging format
>
>   config NET_DSA
> -	tristate
> +	tristate "Distributed Switch Architecture"
>   	depends on HAVE_NET_DSA && NET_SWITCHDEV
>   	select PHYLIB
> +	---help---
> +	  Say Y if you want to enable support for the hardware switches supported
> +	  by the Distributed Switch Architecture.
>
>   if NET_DSA
>
>
