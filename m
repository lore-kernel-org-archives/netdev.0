From: Shrikrishna Khare <skhare@shri-linux.eng.vmware.com>
Subject: Re: [PATCH v2] vmxnet3: fix non static symbol warning
Date: Wed, 24 Aug 2016 08:22:20 -0700
Message-ID: <alpine.DEB.2.10.1608240822001.26950@shri-linux.eng.vmware.com>
References: <1471964718-32543-1-git-send-email-weiyj.lk@gmail.com> <1472051246-15097-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"; format=flowed
Cc: Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-002.vmware.com ([208.91.0.190]:34682 "EHLO
        EX13-EDG-OU-002.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754045AbcHXPXI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:23:08 -0400
In-Reply-To: <1472051246-15097-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 24 Aug 2016, Wei Yongjun wrote:

> From: Wei Yongjun <weiyongjun1@huawei.com>
>
> Fixes the following sparse warning:
>
> drivers/net/vmxnet3/vmxnet3_drv.c:1645:1: warning:
> symbol 'vmxnet3_rq_destroy_all_rxdataring' was not declared. Should it be static?
>
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>

> ---
> v1 -> v2: rebase on netdev tree
> ---
> drivers/net/vmxnet3/vmxnet3_drv.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 4244b9d..2fd93b4 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -1641,7 +1641,7 @@ static void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
> 	}
> }
>
> -void
> +static void
> vmxnet3_rq_destroy_all_rxdataring(struct vmxnet3_adapter *adapter)
> {
> 	int i;
>
>
