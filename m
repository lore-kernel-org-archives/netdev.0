From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH v2 2/2 scsi-post-merge] cxgb3i: support of private MAC
 address in iSCSI
Date: Fri, 25 Sep 2009 19:36:10 -0500
Message-ID: <4ABD61FA.2040609@cs.wisc.edu>
References: <200909252225.n8PMPaa4031752@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	swise@opengridcomputing.com, divy@chelsio.com, rakesh@chelsio.com,
	linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kxie@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200909252225.n8PMPaa4031752@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kxie@chelsio.com wrote:
> [PATCH v2 2/2 scsi-post-merge] cxgb3i: private MAC address for iSCSI
> 
> From: Karen Xie <kxie@chelsio.com>
>         
> This patch updated the use of private MAC address per port in iscsi.
> 
> This patch is generated against scsi-post-merge.
>              
> Signed-off-by: Karen Xie <kxie@chelsio.com>
> --- 
>  drivers/scsi/cxgb3i/cxgb3i_offload.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/drivers/scsi/cxgb3i/cxgb3i_offload.h b/drivers/scsi/cxgb3i/cxgb3i_offload.h
> index 6a1d86b..f585ece 100644
> --- a/drivers/scsi/cxgb3i/cxgb3i_offload.h
> +++ b/drivers/scsi/cxgb3i/cxgb3i_offload.h
> @@ -234,9 +234,9 @@ struct sge_opaque_hdr {
>   * get and set private ip for iscsi traffic
>   */
>  #define cxgb3i_get_private_ipv4addr(ndev) \
> -	(((struct port_info *)(netdev_priv(ndev)))->iscsi_ipv4addr)
> +	(((struct port_info *)(netdev_priv(ndev)))->iscsic.ipv4_addr)
>  #define cxgb3i_set_private_ipv4addr(ndev, addr) \
> -	(((struct port_info *)(netdev_priv(ndev)))->iscsi_ipv4addr) = addr
> +	(((struct port_info *)(netdev_priv(ndev)))->iscsic.ipv4_addr) = addr
>  

This looks ok.

Reviewed-by Mike Christie <michaelc@cs.wisc.edu>
