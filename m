From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ethernet: micrel: fix some error codes
Date: Fri, 18 Mar 2016 19:40:47 -0400 (EDT)
Message-ID: <20160318.194047.1657460162512006177.davem@davemloft.net>
References: <20160316074510.GF12860@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.rojfors@pelagicore.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160316074510.GF12860@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 16 Mar 2016 10:45:10 +0300

> There were two issues here:
> 1) dma_mapping_error() return true/false but we want to return -ENOMEM
> 2) If dmaengine_prep_slave_sg() failed then "err" wasn't set but
>    presumably that should be -ENOMEM as well.
> 
> I changed the success path to "return 0;" instead of "return ret;" for
> clarity.
> 
> Fixes: 94fe8c683cea ('ks8842: Support DMA when accessed via timberdale')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
