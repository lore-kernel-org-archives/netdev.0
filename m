From: Augusto Mecking Caringi <augustocaringi@gmail.com>
Subject: Re: [PATCH] net: fec: fix spelling mistake "coalesed" -> "coalesced"
Date: Sat, 4 Jun 2016 16:43:04 -0300
Message-ID: <CADFy_4GNq-VQj5kgFsoCiHJTHTo21ZdjijfD=mEM602YCrewEw@mail.gmail.com>
References: <1465066875-7089-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fugang Duan <fugang.duan@nxp.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465066875-7089-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 4, 2016 at 4:01 PM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> trivial fix to spelling mistake in pr_err message
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 3c0255e..96bd210 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -2427,13 +2427,13 @@ fec_enet_set_coalesce(struct net_device *ndev, struct ethtool_coalesce *ec)
>
>         cycle = fec_enet_us_to_itr_clock(ndev, fep->rx_time_itr);
>         if (cycle > 0xFFFF) {
> -               pr_err("Rx coalesed usec exceeed hardware limiation");
> +               pr_err("Rx coalesced usec exceeed hardware limiation");
>                 return -EINVAL;
>         }
>
>         cycle = fec_enet_us_to_itr_clock(ndev, fep->tx_time_itr);
>         if (cycle > 0xFFFF) {
> -               pr_err("Rx coalesed usec exceeed hardware limiation");
> +               pr_err("Rx coalesced usec exceeed hardware limiation");
>                 return -EINVAL;
>         }
>

s/limiation/limitation

-- 
Augusto Mecking Caringi
