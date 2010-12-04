From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: init ingress queue
Date: Sat, 04 Dec 2010 14:36:03 +0100
Message-ID: <4CFA43C3.3070102@gmail.com>
References: <1291465901-3189-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58109 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754932Ab0LDNgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 08:36:10 -0500
Received: by wyb28 with SMTP id 28so10452547wyb.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 05:36:08 -0800 (PST)
In-Reply-To: <1291465901-3189-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> The dev field of ingress queue is forgot to initialized, then NULL
> pointer dereference happens in qdisc_alloc().
> 
> Move inits of tx queues to netif_alloc_netdev_queues().
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
> v2: factorize the two inits in netdev_init_queues() and move inits of
>     tx queues to netif_alloc_netdev_queues().
>  net/core/dev.c |   35 +++++++++++++----------------------
>  1 file changed, 13 insertions(+), 22 deletions(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index cd24374..4a7fc32 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c

I guess you should mention it's net-next problem, because some people
might be unnecessarily concerned (why they don't have such an oops ;-)

Jarek P.
