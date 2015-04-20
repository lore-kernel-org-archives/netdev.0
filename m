From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: use PORT_DEFAULT_VLAN
Date: Tue, 21 Apr 2015 01:00:28 +0200
Message-ID: <20150420230028.GB32294@lunn.ch>
References: <1429566206-14809-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429566206-14809-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 20, 2015 at 05:43:26PM -0400, Vivien Didelot wrote:
> Minor, use the explicit PORT_DEFAULT_VLAN define instead of 0x07.

Hi Vivien

I would not normally use the word "Minor" here, since it will end up
in the commit log.

Other than that:

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 48712bd..af639ab 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1274,7 +1274,8 @@ int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
>  	/* Default VLAN ID and priority: don't set a default VLAN
>  	 * ID, and set the default packet priority to zero.
>  	 */
> -	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x07, 0x0000);
> +	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
> +				   0x0000);
>  abort:
>  	mutex_unlock(&ps->smi_mutex);
>  	return ret;
> -- 
> 2.3.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
