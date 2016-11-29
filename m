From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Mon, 28 Nov 2016 20:33:55 -0800
Message-ID: <CAM_iQpWE2ZZLyT6wi7WVUOWs_m=CSEtH0magKgt8JafZLBf0ig@mail.gmail.com>
References: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
 <1480133493.8455.584.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480136078.8455.589.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+7arMOHSwDhE5npH_82R9LTNrmny6jK1H-fkW2+9Jcg@mail.gmail.com>
 <1480213570.18162.31.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUnz2kkjOFuk3fKKEYDh54b9WHk1dvH098mGtrGTPjZFQ@mail.gmail.com>
 <1480263824.18162.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXB_LRqE83cWwU0ZDckLWPrMcZg-yD4+NKy+rBVz3YAyw@mail.gmail.com> <20161128112211.GA990@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Thomas Graf <tgraf@suug.ch>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33289 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752240AbcK2EeR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 23:34:17 -0500
Received: by mail-io0-f170.google.com with SMTP id j65so270428499iof.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 20:34:17 -0800 (PST)
In-Reply-To: <20161128112211.GA990@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 3:22 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> netlink: Call cb->done from a worker thread
>
> The cb->done interface expects to be called in process context.
> This was broken by the netlink RCU conversion.  This patch fixes
> it by adding a worker struct to make the cb->done call where
> necessary.
>
> Fixes: 21e4902aea80 ("netlink: Lockless lookup with RCU grace...")
> Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>


Looks good,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
