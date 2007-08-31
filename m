From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.23 1/2] cxgb3 - Fix dev->priv usage
Date: Fri, 31 Aug 2007 07:41:06 -0400
Message-ID: <46D7FE52.8020807@garzik.org>
References: <20070830021547.21475.62560.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965080AbXHaLlX@vger.kernel.org>
In-Reply-To: <20070830021547.21475.62560.stgit@speedy5>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> cxgb3 used netdev_priv() and dev->priv for different purposes.
> In 2.6.23, netdev_priv() == dev->priv, cxgb3 needs a fix.
> This patch is a partial backport of Dave Miller's changes in the 
> net-2.6.24 git branch. 
> 
> Without this fix, cxgb3 crashes on 2.6.23.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/infiniband/hw/cxgb3/cxio_hal.c |    2 -
>  drivers/net/cxgb3/adapter.h            |    2 +
>  drivers/net/cxgb3/cxgb3_main.c         |  126 ++++++++++++++++++--------------
>  drivers/net/cxgb3/cxgb3_offload.c      |   16 +++-
>  drivers/net/cxgb3/cxgb3_offload.h      |    2 +
>  drivers/net/cxgb3/sge.c                |   23 ++++--
>  drivers/net/cxgb3/t3cdev.h             |    3 -
>  7 files changed, 105 insertions(+), 69 deletions(-)

applied 1-2
