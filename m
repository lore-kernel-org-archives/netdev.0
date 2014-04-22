From: Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH] netclassid_cgroup: explicitly init the early_init field
Date: Tue, 22 Apr 2014 14:28:34 +0800
Message-ID: <53560C12.2050309@huawei.com>
References: <1398144676-9739-1-git-send-email-nasa4836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <tj@kernel.org>, <nhorman@tuxdriver.com>,
	<aris@redhat.com>, <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398144676-9739-1-git-send-email-nasa4836@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/4/22 13:31, Jianyu Zhan wrote:
> For a cgroup subsystem who should init early, then it should carefully
> take care of the implementation of css_alloc, because it will be called
> before mm_init() setup the world.
> 
> Luckily we don't, and we better explicitly assign the early_init field
> to 0, for document reason.
> 

The initialization is redundant, and your reason is not reasonable.

> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

nack

> ---
>  net/core/netclassid_cgroup.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
> index 22931e1..1b07dca 100644
> --- a/net/core/netclassid_cgroup.c
> +++ b/net/core/netclassid_cgroup.c
> @@ -108,4 +108,5 @@ struct cgroup_subsys net_cls_cgrp_subsys = {
>  	.css_free		= cgrp_css_free,
>  	.attach			= cgrp_attach,
>  	.base_cftypes		= ss_files,
> +	.early_init		= 0,
>  };
> 
