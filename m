From: Jeff Garzik <jgarzik@pobox.com>
Subject: [ofa-general] Re: [PATCH] mlx4_en: Start port error flow bug fix
Date: Thu, 06 Nov 2008 00:43:31 -0500
Message-ID: <49128403.6000205@pobox.com>
References: <4911B37E.3020900@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	general@lists.openfabrics.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <4911B37E.3020900@mellanox.co.il>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Yevgeny Petrilin wrote:
> Tried to deactivate rx ring that wasn't activated,
> used wrong index.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/mlx4/en_netdev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
> index 12d736a..96e709d 100644
> --- a/drivers/net/mlx4/en_netdev.c
> +++ b/drivers/net/mlx4/en_netdev.c
> @@ -706,7 +706,7 @@ tx_err:
>  	mlx4_en_release_rss_steer(priv);
>  rx_err:
>  	for (i = 0; i < priv->rx_ring_num; i++)
> -		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[rx_index]);
> +		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
>  cq_err:

applied
