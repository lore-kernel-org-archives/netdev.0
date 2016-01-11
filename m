From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCHv2 net-next 0/3] cxgb4/cxgb4i: add iscsi LRO  support for
 chelsio t4/t5 adapters
Date: Mon, 11 Jan 2016 14:41:09 -0600
Message-ID: <56941365.6080905@cs.wisc.edu>
References: <1452158647-9714-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, JBottomley@odin.com,
	martin.petersen@oracle.com, leedom@chelsio.com, kxie@chelsio.com,
	manojmalviya@chelsio.com, nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1452158647-9714-1-git-send-email-hariprasad@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/07/2016 03:24 AM, Hariprasad Shenai wrote:
> Hi
> 
> This patch series adds LRO iscsi support for chelsio T4/T5 adapters.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 and cxgb4i driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.
> 
> Thanks
> 
> V2:
>  Missed a new header file cxgbi_lro.h in PATCH 2/3. Adding it.
>  Based on failure reported by by kbuild test bot <lkp@intel.com>
> 
> Hariprasad Shenai (3):
>   cxgb4: Add LRO infrastructure for cxgb4i driver
>   libcxgbi: add pdu parsing of LRO'ed skbs
>   cxgb4i: add iscsi LRO for chelsio t4/t5 adapters
> 
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  15 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  40 ++-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   5 +
>  drivers/net/ethernet/chelsio/cxgb4/sge.c        |  10 +-
>  drivers/scsi/cxgbi/cxgb4i/cxgb4i.c              | 396 +++++++++++++++++++++-
>  drivers/scsi/cxgbi/cxgbi_lro.h                  |  72 ++++
>  drivers/scsi/cxgbi/libcxgbi.c                   | 415 +++++++++++++++++++-----
>  drivers/scsi/cxgbi/libcxgbi.h                   |   4 +
>  8 files changed, 840 insertions(+), 117 deletions(-)
>  create mode 100644 drivers/scsi/cxgbi/cxgbi_lro.h
> 

For the iscsi/scsi parts:

Reviewed-by: Mike Christie <michaelc@cs.wisc.edu>
