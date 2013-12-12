From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ipv6: fix incorrect type in initializer
Date: Thu, 12 Dec 2013 18:36:06 +0400
Message-ID: <52A9C9D6.7040200@cogentembedded.com>
References: <1386844881-32017-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:35253 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395Ab3LLOgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 09:36:04 -0500
Received: by mail-la0-f48.google.com with SMTP id n7so369845lam.21
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 06:36:03 -0800 (PST)
In-Reply-To: <1386844881-32017-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-12-2013 14:41, Florent Fourcot wrote:

    s/initializer/declaration/.

> Introduced by 1397ed35f22d7c30d0b89ba74b6b7829220dfcfd
>    "ipv6: add flowinfo for tcp6 pkt_options for all cases"

> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> ---
>   net/ipv6/ipv6_sockglue.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index bc4d8a2..dac04d2 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -1035,7 +1035,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
>   				put_cmsg(&msg, SOL_IPV6, IPV6_2292HOPLIMIT, sizeof(hlim), &hlim);
>   			}
>   			if (np->rxopt.bits.rxflow) {
> -				int flowinfo = np->rcv_flowinfo;
> +				__be32 flowinfo = np->rcv_flowinfo;

    Empty line wouldn't hurt here, after declaration.

>   				put_cmsg(&msg, SOL_IPV6, IPV6_FLOWINFO, sizeof(flowinfo), &flowinfo);

WBR, Sergei
