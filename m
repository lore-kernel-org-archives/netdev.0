From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5 (resend)] net: Loopback ifindex is constant now
Date: Tue, 07 Aug 2012 15:13:54 +0200
Message-ID: <1344345234.28967.89.camel@edumazet-glaptop>
References: <501FD0F2.4040609@parallels.com> <501FD170.90207@parallels.com>
	 <5020F5E3.5050900@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58223 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628Ab2HGNN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 09:13:59 -0400
Received: by bkwj10 with SMTP id j10so1439595bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 06:13:58 -0700 (PDT)
In-Reply-To: <5020F5E3.5050900@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 15:02 +0400, Pavel Emelyanov wrote:
> As pointed out, there are places, that access net->loopback_dev->ifindex
> and after ifindex generation is made per-net this value becomes constant
> equals 1. So go ahead and introduce the LOOPBACK_IFINDEX constant and use
> it where appropriate.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> ---
>  drivers/net/loopback.c            |    1 +
>  include/net/net_namespace.h       |    7 +++++++
>  net/decnet/dn_route.c             |    6 +++---
>  net/ipv4/fib_frontend.c           |    2 +-
>  net/ipv4/ipmr.c                   |    2 +-
>  net/ipv4/netfilter/ipt_rpfilter.c |    2 +-
>  net/ipv4/route.c                  |    6 +++---
>  net/ipv6/route.c                  |    2 +-
>  8 files changed, 18 insertions(+), 10 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
