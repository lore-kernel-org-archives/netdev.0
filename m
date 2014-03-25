From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 44/54] tilepro: Call dev_consume_skb_any instead of
 kfree_skb.
Date: Tue, 25 Mar 2014 13:43:45 -0700
Message-ID: <1395780225.12610.174.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-44-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:38541 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487AbaCYUns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 16:43:48 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so934927pdj.41
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 13:43:48 -0700 (PDT)
In-Reply-To: <1395727540-12148-44-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace kfree_skb with dev_consume_skb_any in tile_net_tx and
> tile_net_tx_tso which can be called in hard irq and other contexts.
> 
> At the point where the skbs are freed a packet has been successfully
> transmitted so dev_consume_skb_any is the appropriate variant to use.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/tile/tilepro.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
