From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v5 net-next 1/4] sh_eth: Use bool as return type of
 sh_eth_is_gether()
Date: Wed, 15 Jan 2014 01:35:20 -0800
Message-ID: <1389778520.14001.16.camel@joe-AO722>
References: <1389766341-14001-1-git-send-email-horms+renesas@verge.net.au>
	 <1389766341-14001-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1389766341-14001-2-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-01-15 at 15:12 +0900, Simon Horman wrote:
> Return a boolean and use true and false.
[]
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
[]
> @@ -310,12 +310,12 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
>  	[TSU_ADRL31]	= 0x01fc,
>  };
>  
> -static int sh_eth_is_gether(struct sh_eth_private *mdp)
> +static bool sh_eth_is_gether(struct sh_eth_private *mdp)
>  {
>  	if (mdp->reg_offset == sh_eth_offset_gigabit)
> -		return 1;
> +		return true;
>  	else
> -		return 0;
> +		return false;
>  }

Or maybe:

static bool sh_eth_is_gether(struct sh_eth_private *mdp)
{
	return mdp->reg_offset == sh_eth_offset_gigabit;
}


