From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net] net/mlx4: Avoid wrong virtual mappings
Date: Tue, 03 May 2016 12:41:04 -0400 (EDT)
Message-ID: <20160503.124104.1688920577838790285.davem@davemloft.net>
References: <1461740820-15386-1-git-send-email-hagaya@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, okaya@codeaurora.org, timur@codeaurora.org,
	eli@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com,
	yishaih@mellanox.com, talal@mellanox.com, saeedm@mellanox.com
To: hagaya@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933842AbcECQlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 12:41:07 -0400
In-Reply-To: <1461740820-15386-1-git-send-email-hagaya@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haggai Abramovsky <hagaya@mellanox.com>
Date: Wed, 27 Apr 2016 10:07:00 +0300

> @@ -419,7 +419,8 @@ static int set_rq_size(struct mlx4_ib_dev *dev, struct ib_qp_cap *cap,
>  }
>  
>  static int set_kernel_sq_size(struct mlx4_ib_dev *dev, struct ib_qp_cap *cap,
> -			      enum mlx4_ib_qp_type type, struct mlx4_ib_qp *qp)
> +			      enum mlx4_ib_qp_type type, struct mlx4_ib_qp *qp,
> +			      int shrink_wqe)
>  {
>  	int s;
>  

Please use 'bool' and "true/false" for shrink_wqe.
