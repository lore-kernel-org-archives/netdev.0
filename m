From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] drivers/net: replace IS_ERR and PTR_ERR with PTR_ERR_OR_ZERO
Date: Fri, 01 Nov 2013 17:38:42 +0400
Message-ID: <5273AEE2.2010005@cogentembedded.com>
References: <1383300016-5947-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>, acme@ghostprotocols.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383300016-5947-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01-11-2013 14:00, Duan Jiong wrote:

> This patch fixes coccinelle error regarding usage of IS_ERR and
> PTR_ERR instead of PTR_ERR_OR_ZERO.

> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>   drivers/net/appletalk/ipddp.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)

> diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
> index 10d0dba..78f06cb 100644
> --- a/drivers/net/appletalk/ipddp.c
> +++ b/drivers/net/appletalk/ipddp.c
> @@ -312,9 +312,7 @@ module_param(ipddp_mode, int, 0);
>   static int __init ipddp_init_module(void)
>   {
>   	dev_ipddp = ipddp_init();
> -        if (IS_ERR(dev_ipddp))
> -                return PTR_ERR(dev_ipddp);
> -	return 0;
> +        return PTR_ERR_OR_ZERO(dev_ipddp);

    Indent with a tab, please.

WBR, Sergei
