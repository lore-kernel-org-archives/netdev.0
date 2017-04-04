From: Max Gurtovoy <maxg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH rfc 0/6] Automatic affinity settings for nvme over rdma
Date: Tue, 4 Apr 2017 10:51:47 +0300
Message-ID: <86ed1762-a990-691f-e043-3d7dcac8fe85@mellanox.com>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
To: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1491140492-25703-1-git-send-email-sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>
> Any feedback is welcome.

Hi Sagi,

the patchset looks good and of course we can add support for more 
drivers in the future.
have you run some performance testing with the nvmf initiator ?


>
> Sagi Grimberg (6):
>   mlx5: convert to generic pci_alloc_irq_vectors
>   mlx5: move affinity hints assignments to generic code
>   RDMA/core: expose affinity mappings per completion vector
>   mlx5: support ->get_vector_affinity
>   block: Add rdma affinity based queue mapping helper
>   nvme-rdma: use intelligent affinity based queue mappings
>
>  block/Kconfig                                      |   5 +
>  block/Makefile                                     |   1 +
>  block/blk-mq-rdma.c                                |  56 +++++++++++
>  drivers/infiniband/hw/mlx5/main.c                  |  10 ++
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   5 +-
>  drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   9 +-
>  drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   2 +-
>  drivers/net/ethernet/mellanox/mlx5/core/health.c   |   2 +-
>  drivers/net/ethernet/mellanox/mlx5/core/main.c     | 106 +++------------------
>  .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   1 -
>  drivers/nvme/host/rdma.c                           |  13 +++
>  include/linux/blk-mq-rdma.h                        |  10 ++
>  include/linux/mlx5/driver.h                        |   2 -
>  include/rdma/ib_verbs.h                            |  24 +++++
>  14 files changed, 138 insertions(+), 108 deletions(-)
>  create mode 100644 block/blk-mq-rdma.c
>  create mode 100644 include/linux/blk-mq-rdma.h
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
