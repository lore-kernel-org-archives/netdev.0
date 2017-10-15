From: Koichiro Den <den@klaipeden.com>
Subject: Re: [net-next 2/3] tcp: do not tcp_collapse once SYN or FIN found
Date: Sun, 15 Oct 2017 11:43:40 +0900
Message-ID: <1508035420.29679.3.camel@klaipeden.com>
References: <20171014072745.23462-1-den@klaipeden.com>
         <20171014072745.23462-3-den@klaipeden.com>
         <1507995823.31614.57.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21443 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdJOCnp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 22:43:45 -0400
In-Reply-To: <1507995823.31614.57.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-10-14 at 08:43 -0700, Eric Dumazet wrote:
> On Sat, 2017-10-14 at 16:27 +0900, Koichiro Den wrote:
> > Since 9f5afeae5152 ("tcp: use an RB tree for ooo receive queue")
> > applied, we no longer need to continue to search for the starting
> > point once we encounter FIN packet. Same reasoning for SYN packet
> > since commit 9d691539eea2d ("tcp: do not enqueue skb with SYN flag"),
> > that would help us with error message when actual receiving.
> 
> Very confusing changelog or patch.
> 
> What exact problem do you want to solve ?
> 
> 
That I thought as unnecessary search for the starting point. I am going to re-
read all to correct my misunderstanding.
Thank you.
