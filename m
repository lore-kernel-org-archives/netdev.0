From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC(v2) net-next 12/13] ipv6: Remove temporary dst for icmpv6.
Date: Wed, 16 Jan 2013 15:02:19 +0800
Message-ID: <50F6507B.5030908@gmail.com>
References: <50F587E8.1060308@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:58615 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab3APHC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 02:02:29 -0500
Received: by mail-pb0-f48.google.com with SMTP id rq13so562050pbb.7
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 23:02:28 -0800 (PST)
In-Reply-To: <50F587E8.1060308@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2013 12:46 AM, YOSHIFUJI Hideaki wrote:
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>   net/ipv6/ip6_fib.c |    2 +-
>   net/ipv6/route.c   |   98 ----------------------------------------------------
>   2 files changed, 1 insertion(+), 99 deletions(-)
[...]
> -
> -int icmp6_dst_gc(void)
> -{

Please remove its declaration too:
include/net/ip6_route.h:extern int icmp6_dst_gc(void);
