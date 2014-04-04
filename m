From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ipv6: recompute the array size
Date: Fri, 04 Apr 2014 16:34:00 +0400
Message-ID: <533EA6B8.9020007@cogentembedded.com>
References: <1396594286-21788-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:48589 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbaDDMdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 08:33:52 -0400
Received: by mail-la0-f41.google.com with SMTP id gl10so2487716lab.28
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 05:33:51 -0700 (PDT)
In-Reply-To: <1396594286-21788-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04-04-2014 10:51, roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>

> recompute the array size to kill the warning:
>   net/ipv6/xfrm6_state.c:66:26: error: cannot size expression

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>   net/ipv6/xfrm6_state.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
> index 3fc9701..9e08572 100644
> --- a/net/ipv6/xfrm6_state.c
> +++ b/net/ipv6/xfrm6_state.c
> @@ -63,7 +63,7 @@ __xfrm6_sort(void **dst, void **src, int n, int (*cmp)(void *p), int maxclass)
>   	int class[XFRM_MAX_DEPTH];
>   	int count[maxclass];
>
> -	memset(count, 0, sizeof(count));
> +	memset(count, 0, sizeof(int)*maxclass);

    Please insert spaces before and after *.

WBR, Sergei
