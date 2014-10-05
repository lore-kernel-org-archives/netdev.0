From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: igmp: fix v3 general query drop monitor
 false positive
Date: Sun, 05 Oct 2014 10:12:27 -0700
Message-ID: <1412529147.11091.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412522870-26335-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:47099 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbaJERM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 13:12:29 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so2120258pdj.9
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 10:12:29 -0700 (PDT)
In-Reply-To: <1412522870-26335-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-10-05 at 17:27 +0200, Daniel Borkmann wrote:
> In case we find a general query with non-zero number of sources, we
> are dropping the skb as it's malformed.
> 
> RFC3376, section 4.1.8. Number of Sources (N):
> 
>   This number is zero in a General Query or a Group-Specific Query,
>   and non-zero in a Group-and-Source-Specific Query.
> 
> Therefore, reflect that by using kfree_skb() instead of consume_skb().
> 
> Fixes: d679c5324d9a ("igmp: avoid drop_monitor false positives")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
