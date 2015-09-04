From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6171: add hardware 802.1Q support
Date: Fri, 4 Sep 2015 17:47:00 +0200
Message-ID: <20150904154700.GC28899@lunn.ch>
References: <1441380144-26205-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1441380144-26205-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 11:22:24AM -0400, Vivien Didelot wrote:
> The Marvell 88E6171 switch is in the 88E6351 family, which supports
> 802.1Q, thus add support from the generic mv88e6xxx functions.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
>  drivers/net/dsa/mv88e6171.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
> index d54b740..c2daaf0 100644
> --- a/drivers/net/dsa/mv88e6171.c
> +++ b/drivers/net/dsa/mv88e6171.c
> @@ -117,6 +117,11 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
>  	.port_join_bridge       = mv88e6xxx_join_bridge,
>  	.port_leave_bridge      = mv88e6xxx_leave_bridge,
>  	.port_stp_update        = mv88e6xxx_port_stp_update,
> +	.port_pvid_get		= mv88e6xxx_port_pvid_get,
> +	.port_pvid_set		= mv88e6xxx_port_pvid_set,
> +	.port_vlan_add		= mv88e6xxx_port_vlan_add,
> +	.port_vlan_del		= mv88e6xxx_port_vlan_del,
> +	.vlan_getnext		= mv88e6xxx_vlan_getnext,
>  	.port_fdb_add		= mv88e6xxx_port_fdb_add,
>  	.port_fdb_del		= mv88e6xxx_port_fdb_del,
>  	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
> -- 
> 2.5.1
> 
