From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bnxt: add dma mapping attributes
Date: Tue, 16 May 2017 11:53:25 -0400 (EDT)
Message-ID: <20170516.115325.904175179446683748.davem@davemloft.net>
References: <1494379812-282087-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        michael.chan@broadcom.com
To: shannon.nelson@oracle.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1494379812-282087-1-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Tue,  9 May 2017 18:30:12 -0700

> On the SPARC platform we need to use the DMA_ATTR_WEAK_ORDERING attribute
> in our Rx path dma mapping in order to get the expected performance out
> of the receive path.  Adding it to the Tx path has little effect, so
> that's not a part of this patch.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> Reviewed-by: Tushar Dave <tushar.n.dave@oracle.com>
> Reviewed-by: Tom Saeger <tom.saeger@oracle.com>
> ---
> v2: simplify by getting rid of the driver-specific ifdef and define

Applied.
