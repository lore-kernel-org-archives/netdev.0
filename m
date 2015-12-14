From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] ravb: Add disable 10base
Date: Mon, 14 Dec 2015 20:31:27 +0300
Message-ID: <566EFCEF.2030200@cogentembedded.com>
References: <1450019758-32710-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1450019758-32710-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/13/2015 06:15 PM, Yoshihiro Kaneko wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> Ethernet AVB does not support 10 Mbps transfer speed.
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---
>
> This patch is based on the master branch of David Miller's networking
> tree.
>
>   drivers/net/ethernet/renesas/ravb_main.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index b69e0c2..467d416 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -905,6 +905,9 @@ static int ravb_phy_init(struct net_device *ndev)
>   		netdev_info(ndev, "limited PHY to 100Mbit/s\n");
>   	}
>
> +	/* 10BASE is not supported */
> +	phydev->supported &= ~PHY_10BT_FEATURES;

    I wonder if we should also modify 'phydev->advertising' like 
phy_set_max_speed() does...

MBR, Sergei

