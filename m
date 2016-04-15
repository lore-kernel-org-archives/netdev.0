From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 1/7] net: dsa: mv88e6xxx: drop double ds
 assignment
Date: Sat, 16 Apr 2016 01:39:17 +0200
Message-ID: <20160415233917.GA32136@lunn.ch>
References: <1460762488-2633-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460762488-2633-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460762488-2633-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 07:21:22PM -0400, Vivien Didelot wrote:
> Every driver assigns ps->ds even though it gets assigned in the shared
> mv88e6xxx_setup_common function. Kill redundancy.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
>  drivers/net/dsa/mv88e6123.c | 2 --
>  drivers/net/dsa/mv88e6131.c | 2 --
>  drivers/net/dsa/mv88e6171.c | 2 --
>  drivers/net/dsa/mv88e6352.c | 2 --
>  4 files changed, 8 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
> index c34283d..88a812d 100644
> --- a/drivers/net/dsa/mv88e6123.c
> +++ b/drivers/net/dsa/mv88e6123.c
> @@ -76,8 +76,6 @@ static int mv88e6123_setup(struct dsa_switch *ds)
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>  	int ret;
>  
> -	ps->ds = ds;
> -
>  	ret = mv88e6xxx_setup_common(ds);
>  	if (ret < 0)
>  		return ret;
> diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
> index f5d75fc..6b2bcb0 100644
> --- a/drivers/net/dsa/mv88e6131.c
> +++ b/drivers/net/dsa/mv88e6131.c
> @@ -94,8 +94,6 @@ static int mv88e6131_setup(struct dsa_switch *ds)
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>  	int ret;
>  
> -	ps->ds = ds;
> -
>  	ret = mv88e6xxx_setup_common(ds);
>  	if (ret < 0)
>  		return ret;
> diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
> index f562250..40222b0 100644
> --- a/drivers/net/dsa/mv88e6171.c
> +++ b/drivers/net/dsa/mv88e6171.c
> @@ -72,8 +72,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>  	int ret;
>  
> -	ps->ds = ds;
> -
>  	ret = mv88e6xxx_setup_common(ds);
>  	if (ret < 0)
>  		return ret;
> diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
> index e54ee27..dbd920e 100644
> --- a/drivers/net/dsa/mv88e6352.c
> +++ b/drivers/net/dsa/mv88e6352.c
> @@ -84,8 +84,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>  	int ret;
>  
> -	ps->ds = ds;
> -
>  	ret = mv88e6xxx_setup_common(ds);
>  	if (ret < 0)
>  		return ret;
> -- 
> 2.8.0
> 
