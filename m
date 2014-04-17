From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [patch net-next RFC v3 02/10] net: rename
 netdev_phys_port_id to more generic name
Date: Thu, 17 Apr 2014 08:01:10 -0700
Message-ID: <20140417080110.73485409@nehalam.linuxnetplumber.net>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
 <1397736876-11771-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1397736876-11771-3-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, 17 Apr 2014 14:14:29 +0200
Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org> wrote:

> So this can be reused for identification of other "items" as well.
> 
> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  2 +-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  2 +-
>  include/linux/netdevice.h                        | 16 ++++++++--------
>  net/core/dev.c                                   |  2 +-
>  net/core/net-sysfs.c                             |  2 +-
>  net/core/rtnetlink.c                             |  6 +++---
>  7 files changed, 16 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index a78edac..a4b25b1 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -12360,7 +12360,7 @@ static int bnx2x_validate_addr(struct net_device *dev)
>  }
>  
>  static int bnx2x_get_phys_port_id(struct net_device *netdev,
> -				  struct netdev_phys_port_id *ppid)
> +				  struct netdev_phys_item_id *ppid)
>  {
>  	struct bnx2x *bp = netdev_priv(netdev);
>  
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index f085c2d..e784bb4 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2251,7 +2251,7 @@ static int mlx4_en_set_vf_link_state(struct net_device *dev, int vf, int link_st
>  
>  #define PORT_ID_BYTE_LEN 8
>  static int mlx4_en_get_phys_port_id(struct net_device *dev,
> -				    struct netdev_phys_port_id *ppid)
> +				    struct netdev_phys_item_id *ppid)
>  {
>  	struct mlx4_en_priv *priv = netdev_priv(dev);
>  	struct mlx4_dev *mdev = priv->mdev->dev;
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 309d056..55af16a 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -450,7 +450,7 @@ static void qlcnic_82xx_cancel_idc_work(struct qlcnic_adapter *adapter)
>  }
>  
>  static int qlcnic_get_phys_port_id(struct net_device *netdev,
> -				   struct netdev_phys_port_id *ppid)
> +				   struct netdev_phys_item_id *ppid)
>  {
>  	struct qlcnic_adapter *adapter = netdev_priv(netdev);
>  	struct qlcnic_hardware_context *ahw = adapter->ahw;
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 775cc95..8cf4f5e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -735,13 +735,13 @@ struct netdev_fcoe_hbainfo {
>  };
>  #endif
>  
> -#define MAX_PHYS_PORT_ID_LEN 32
> +#define MAX_PHYS_ITEM_ID_LEN 32
>  

Why the rename?
