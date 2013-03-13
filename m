From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] tuntap: remove unused variable in __tun_detach()
Date: Wed, 13 Mar 2013 09:30:49 -0400
Message-ID: <20130313133049.GC17592@hmsreliant.think-freely.org>
References: <CAPgLHd-v-daRHrDqoencJOTTvxLU_RD44BWzvdHd6j5Qrr8J5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	edumazet@google.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46932 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569Ab3CMNbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 09:31:03 -0400
Content-Disposition: inline
In-Reply-To: <CAPgLHd-v-daRHrDqoencJOTTvxLU_RD44BWzvdHd6j5Qrr8J5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 09:03:58PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The variable dev is initialized but never used
> otherwise, so remove the unused variable.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/tun.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index b7c457a..95837c1 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -409,14 +409,12 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
>  {
>  	struct tun_file *ntfile;
>  	struct tun_struct *tun;
> -	struct net_device *dev;
>  
>  	tun = rtnl_dereference(tfile->tun);
>  
>  	if (tun && !tfile->detached) {
>  		u16 index = tfile->queue_index;
>  		BUG_ON(index >= tun->numqueues);
> -		dev = tun->dev;
>  
>  		rcu_assign_pointer(tun->tfiles[index],
>  				   tun->tfiles[tun->numqueues - 1]);
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
