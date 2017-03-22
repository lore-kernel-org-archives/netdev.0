From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] net: dwc-xlgmac: fix an error code in
 xlgmac_alloc_pages()
Date: Wed, 22 Mar 2017 12:46:29 -0700 (PDT)
Message-ID: <20170322.124629.675577955142901395.davem@davemloft.net>
References: <20170321204227.GB22118@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiedeng@synopsys.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170321204227.GB22118@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 21 Mar 2017 23:42:27 +0300

> The dma_mapping_error() returns true if there is an error but we want
> to return -ENOMEM and not 1.
> 
> Fixes: 65e0ace2c5cd ("net: dwc-xlgmac: Initial driver for DesignWare Enterprise Ethernet")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
