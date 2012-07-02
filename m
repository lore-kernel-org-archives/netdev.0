From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] ipv4: Delete routing cache.
Date: Mon, 02 Jul 2012 11:35:12 +0200
Message-ID: <1341221712.5269.40.camel@edumazet-glaptop>
References: <20120701.050249.1959437975207758368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42351 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932718Ab2GBJfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 05:35:16 -0400
Received: by eeit10 with SMTP id t10so1981984eei.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 02:35:15 -0700 (PDT)
In-Reply-To: <20120701.050249.1959437975207758368.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-01 at 05:02 -0700, David Miller wrote:
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/net/route.h     |    5 +-
>  net/ipv4/fib_frontend.c |    5 -
>  net/ipv4/icmp.c         |    5 +-
>  net/ipv4/route.c        | 1053 +++--------------------------------------------
>  4 files changed, 52 insertions(+), 1016 deletions(-)

When testing this patch, I had to disable CONFIG_IP_ROUTE_VERBOSE to
avoid a compile error at the end of ip_rt_redirect()
