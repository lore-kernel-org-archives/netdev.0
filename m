From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] chcr/cxgb4i/cxgbit/RDMA/cxgb4: Allocate
 resources dynamically for all cxgb4 ULD's
Date: Mon, 19 Sep 2016 01:38:06 -0400 (EDT)
Message-ID: <20160919.013806.1060448921542204830.davem@davemloft.net>
References: <1474080159-14980-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-crypto@vger.kernel.org, nab@linux-iscsi.org,
        jejb@linux.vnet.ibm.com, martin.petersen@oracle.com,
        dledford@redhat.com, herbert@gondor.apana.org.au,
        varun@chelsio.com, nirranjan@chelsio.com,
        swise@opengridcomputing.com, atul.gupta@chelsio.com,
        rahul.lakkireddy@chelsio.com
To: hariprasad@chelsio.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1474080159-14980-1-git-send-email-hariprasad@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Sat, 17 Sep 2016 08:12:39 +0530

> Allocate resources dynamically to cxgb4's Upper layer driver's(ULD) like
> cxgbit, iw_cxgb4 and cxgb4i. Allocate resources when they register with
> cxgb4 driver and free them while unregistering. All the queues and the
> interrupts for them will be allocated during ULD probe only and freed
> during remove.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
