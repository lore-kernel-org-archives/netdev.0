From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: merge redundancy judgement
Date: Wed, 29 Apr 2015 11:59:32 -0400 (EDT)
Message-ID: <20150429.115932.495579567064625984.davem@davemloft.net>
References: <20150429.002816.509194069032518571.davem@davemloft.net>
	<1430298564-9690-1-git-send-email-martinbj2008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: martinbj2008@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604AbbD2P7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 11:59:38 -0400
In-Reply-To: <1430298564-9690-1-git-send-email-martinbj2008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Zhang <martinbj2008@gmail.com>
Date: Wed, 29 Apr 2015 17:09:24 +0800

> 'if' and 'elseif' do the same operation,
> so merge then into a case.
> 
> Signed-off-by: Martin Zhang <martinbj2008@gmail.com>
> ---
>  net/ipv4/route.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index a78540f..2a50411 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -801,11 +801,8 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
>  	struct dst_entry *ret = dst;
>  
>  	if (rt) {
> -		if (dst->obsolete > 0) {
> -			ip_rt_put(rt);
> -			ret = NULL;
> -		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
> -			   rt->dst.expires) {
> +		if (dst->obsolete > 0 || (rt->rt_flags & RTCF_REDIRECTED) ||
> +			rt->dst.expires) {

This is not indented properly.

When an if() condition spans multiple lines, the second and subsequent lines
must start precisely at the first column after the openning parenthesis of
the first line.  You must use the appropriate number of TAB and SPACE
characters necessary to do so.

You would do well to simply follow the coding style that existed in the
lines you are editing, because you are only running into trouble because
you are styling things differently from what is happening there already.
