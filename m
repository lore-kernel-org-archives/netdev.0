From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net: dsa: mv88e6352: add support for port_vlan_dump
Date: Fri, 26 Jun 2015 16:12:17 +0200
Message-ID: <20150626141217.GD9469@lunn.ch>
References: <1435095970-18576-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1435095970-18576-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435095970-18576-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 23, 2015 at 05:46:10PM -0400, Vivien Didelot wrote:
> Add support for dumping the VLAN Table Unit entries by pointing to the
> port_vlan_dump function implemented for mv88e6xxx.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6352.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
> index b524bd3..c35f57f 100644
> --- a/drivers/net/dsa/mv88e6352.c
> +++ b/drivers/net/dsa/mv88e6352.c
> @@ -397,6 +397,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
>  	.fdb_add		= mv88e6xxx_port_fdb_add,
>  	.fdb_del		= mv88e6xxx_port_fdb_del,
>  	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
> +	.port_vlan_dump		= mv88e6xxx_port_vlan_dump,
>  };

Once the code is made generic in terms of number of ports, i would
suggest adding this to all drivers which support it. Between us, we
can test most of them.

Thanks
	Andrew
