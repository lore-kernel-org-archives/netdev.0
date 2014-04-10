From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] packet: fix potential use after free
Date: Thu, 10 Apr 2014 10:19:21 +0200
Message-ID: <53465409.3070507@redhat.com>
References: <1397092959.16584.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Xi Wang <xii@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965164AbaDJITd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 04:19:33 -0400
In-Reply-To: <1397092959.16584.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2014 03:22 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> As soon skb is queued into sk_receive_queue, it can be consumed,
> so its racy to access skb->len.
>
> Given that sk_data_ready() / sock_def_readable() don't really care, just
> use 0 instead of skb->len
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Xi Wang <xii@google.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

Seems to be there since pre 2005 ...
