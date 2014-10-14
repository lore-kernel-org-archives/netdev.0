From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] dsa: mv88e6171: Fix tag_protocol check
Date: Tue, 14 Oct 2014 21:59:58 +0200
Message-ID: <20141014195958.GB5331@lunn.ch>
References: <1413310864-16830-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413310864-16830-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 14, 2014 at 11:21:04AM -0700, Guenter Roeck wrote:
> tag_protocol is now an enum, so drivers have to check against it.
> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks for fixing this.

       Andrew

> ---
>  drivers/net/dsa/mv88e6171.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
> index 6365e30..1020a7a 100644
> --- a/drivers/net/dsa/mv88e6171.c
> +++ b/drivers/net/dsa/mv88e6171.c
> @@ -206,7 +206,7 @@ static int mv88e6171_setup_port(struct dsa_switch *ds, int p)
>  	 */
>  	val = 0x0433;
>  	if (dsa_is_cpu_port(ds, p)) {
> -		if (ds->dst->tag_protocol == htons(ETH_P_EDSA))
> +		if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
>  			val |= 0x3300;
>  		else
>  			val |= 0x0100;
> -- 
> 1.9.1
> 
