From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Wed, 11 Oct 2017 06:31:45 -0700
Message-ID: <1507728705.31614.24.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
         <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
         <87po9ull5u.fsf@stressinduktion.org>
         <20171011025606.tzts5wgys5hn52p2@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:55613 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbdJKNbr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 09:31:47 -0400
Received: by mail-pf0-f176.google.com with SMTP id 17so1093223pfn.12
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 06:31:47 -0700 (PDT)
In-Reply-To: <20171011025606.tzts5wgys5hn52p2@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-10 at 19:56 -0700, Alexei Starovoitov wrote:

> actually we hit that too for completely different tracing use case.
> Indeed would be good to generate socket cookie unconditionally
> for all sockets. I don't think there is any harm.
> 

Simply call sock_gen_cookie() when needed.

If a tracepoint needs the cookie and the cookie was not yet generated,
it will be generated at this point.
