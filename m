From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v1 2/5] cgroup: net_cls: Fix local variable type
 decleration
Date: Thu, 25 Oct 2012 14:35:16 -0400
Message-ID: <20121025183516.GB15105@hmsreliant.think-freely.org>
References: <1351174619-5096-1-git-send-email-wagi@monom.org>
 <1351174619-5096-3-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41062 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756494Ab2JYSfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 14:35:31 -0400
Content-Disposition: inline
In-Reply-To: <1351174619-5096-3-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 25, 2012 at 04:16:56PM +0200, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
> 
> The classid type used throughout the kernel is u32.
> 
> Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Li Zefan <lizefan@huawei.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: <netdev@vger.kernel.org>
> Cc: <cgroups@vger.kernel.org>
> ---
>  include/net/cls_cgroup.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
> index b6a6eeb..0fee061 100644
> --- a/include/net/cls_cgroup.h
> +++ b/include/net/cls_cgroup.h
> @@ -29,7 +29,7 @@ extern void sock_update_classid(struct sock *sk);
>  #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
>  static inline u32 task_cls_classid(struct task_struct *p)
>  {
> -	int classid;
> +	u32 classid;
>  
>  	if (in_interrupt())
>  		return 0;
> -- 
> 1.8.0.rc0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
