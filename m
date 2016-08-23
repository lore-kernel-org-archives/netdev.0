From: Shrikrishna Khare <skhare@shri-linux.eng.vmware.com>
Subject: Re: [PATCH -next] vmxnet3: fix non static symbol warning
Date: Tue, 23 Aug 2016 10:13:42 -0700
Message-ID: <alpine.DEB.2.10.1608231013030.12888@shri-linux.eng.vmware.com>
References: <1471964718-32543-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"; format=flowed
Cc: Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:45395 "EHLO
        EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753974AbcHWSVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:21:19 -0400
In-Reply-To: <1471964718-32543-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 23 Aug 2016, Wei Yongjun wrote:

> From: Wei Yongjun <weiyongjun1@huawei.com>
>
> Fixes the following sparse warning:
>
> drivers/net/vmxnet3/vmxnet3_drv.c:1645:1: warning:
> symbol 'vmxnet3_rq_destroy_all_rxdataring' was not declared. Should it be static?
>
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Thanks for catching and fixing this. The fix looks good. But, could you 
please send this against net tree instead of net-next?


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
>
>
