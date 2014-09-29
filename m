From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: cleanup and document skb fclone layout
Date: Mon, 29 Sep 2014 10:23:36 -0700
Message-ID: <1412011416.30721.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411860341.15768.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:52935 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715AbaI2RXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 13:23:39 -0400
Received: by mail-pd0-f170.google.com with SMTP id ft15so1871963pdb.1
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 10:23:39 -0700 (PDT)
In-Reply-To: <1411860341.15768.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-27 at 16:25 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Lets use a proper structure to clearly document and implement
> skb fast clones.
> 
> Then, we might experiment more easily alternative layouts.
> 
> This patch adds a new skb_fclone_busy() helper, used by tcp and xfrm.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/skbuff.h |   25 ++++++++++++++++++++++
>  net/core/skbuff.c      |   44 +++++++++++++++++++--------------------
>  net/ipv4/tcp_output.c  |    5 ----
>  net/xfrm/xfrm_policy.c |    4 ---
>  4 files changed, 49 insertions(+), 29 deletions(-)


I'll rebase this patch and send a v2.
