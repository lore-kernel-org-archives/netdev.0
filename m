From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH v3 2/3] gianfar: Delete unnecessary variable
 initialisations in gfar_ethflow_to_filer_table()
Date: Fri, 15 Jan 2016 13:29:47 +0300
Message-ID: <20160115102947.GI4764@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56866E7F.8080609@users.sourceforge.net>
 <5698C53C.8060204@users.sourceforge.net>
 <5698C61A.90504@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5698C61A.90504@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2016 at 11:12:42AM +0100, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 15 Jan 2016 10:40:24 +0100
> 
> Omit explicit initialisation at the beginning for four local variables
> which are redefined before their first use.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/ethernet/freescale/gianfar_ethtool.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> index 825b051..8302f7d 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -768,12 +768,12 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
>  static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
>  				       u64 class)
>  {
> -	unsigned int last_rule_idx = priv->cur_filer_idx;
> +	unsigned int last_rule_idx;

This is a write only variable.  We can just remove it.

regards,
dan carpenter
