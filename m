From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 0/4] various sizeof cleanups
Date: Tue, 15 Aug 2017 22:47:50 +0300
Message-ID: <20170815224731-mutt-send-email-mst@kernel.org>
References: <20170815172919.26153-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <sthemmin@microsoft.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, mlindner@marvell.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170815172919.26153-1-sthemmin@microsoft.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2017 at 10:29:15AM -0700, Stephen Hemminger wrote:
> Noticed some places that were using sizeof as an operator.
> This is legal C but is not the convention used in the kernel.
> 
> Stephen Hemminger (4):
>   tun/tap: use paren's with sizeof
>   virtio: put paren around sizeof
>   skge: add paren around sizeof arg
>   mlx4: sizeof style usage

for tun and virtio:

Acked-by: Michael S. Tsirkin <mst@redhat.com>

>  drivers/net/ethernet/marvell/skge.c                |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/alloc.c         |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/cmd.c           |  4 ++--
>  drivers/net/ethernet/mellanox/mlx4/en_resources.c  |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/eq.c            | 20 +++++++++---------
>  drivers/net/ethernet/mellanox/mlx4/fw.c            |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/icm.c           |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/icm.h           |  4 ++--
>  drivers/net/ethernet/mellanox/mlx4/intf.c          |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/main.c          | 12 +++++------
>  drivers/net/ethernet/mellanox/mlx4/mcg.c           | 12 +++++------
>  drivers/net/ethernet/mellanox/mlx4/mr.c            | 10 ++++-----
>  drivers/net/ethernet/mellanox/mlx4/qp.c            | 12 +++++------
>  .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 24 +++++++++++-----------
>  drivers/net/tap.c                                  |  2 +-
>  drivers/net/tun.c                                  |  2 +-
>  drivers/net/virtio_net.c                           |  2 +-
>  19 files changed, 60 insertions(+), 60 deletions(-)
> 
> -- 
> 2.11.0
