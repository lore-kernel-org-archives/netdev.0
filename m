From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/2] sockmap fixes
Date: Sun, 29 Oct 2017 11:19:06 +0900 (KST)
Message-ID: <20171029.111906.598299267651559854.davem@davemloft.net>
References: <20171027163830.28498.82997.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        edumazet@google.com, daniel@iogearbox.net
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43674 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751676AbdJ2CTL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 22:19:11 -0400
In-Reply-To: <20171027163830.28498.82997.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 27 Oct 2017 09:45:16 -0700

> Last two fixes (as far as I know) for sockmap code this round.
> 
> First, we are using the qdisc cb structure when making the data end
> calculation. This is really just wrong so, store it with the other
> metadata in the correct tcp_skb_cb sturct to avoid breaking things.
> 
> Next, with recent work to attach multiple programs to a cgroup a
> specific enumeration of return codes was agreed upon. However,
> I wrote the sk_skb program types before seeing this work and used
> a different convention. Patch 2 in the series aligns the return
> codes to avoid breaking with this infrastructure and also aligns
> with other programming conventions to avoid being the odd duck out
> forcing programs to remember SK_SKB programs are different. Pusing
> to net because its a user visible change. With this SK_SKB program
> return codes are the same as other cgroup program types.

Series applied, thanks a lot John.
