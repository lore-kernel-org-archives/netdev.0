From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tun: remove copyright printing
Date: Wed, 8 Mar 2017 15:20:48 -0800
Message-ID: <20170308152048.1bf4f6de@xeon-e3>
References: <20170308154657.8988-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170308154657.8988-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  8 Mar 2017 16:46:57 +0100
Corentin Labbe <clabbe.montjoie@gmail.com> wrote:

> Printing copyright does not give any useful information on the boot
> process.
> Furthermore, the email address printed is obsolete since
> commit ba57b6f20429 ("MAINTAINERS: fix bouncing tun/tap entries")
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/net/tun.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index dc1b1dd..f58b7d8 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -2570,7 +2570,6 @@ static int __init tun_init(void)
>  	int ret = 0;
>  
>  	pr_info("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
> -	pr_info("%s\n", DRV_COPYRIGHT);
>  
>  	ret = rtnl_link_register(&tun_link_ops);
>  	if (ret) {

Why not just kill the pr_info() all together.
It is just a vanity message.
