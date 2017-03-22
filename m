From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: provide stronger user input validation in
 nl_fib_input()
Date: Wed, 22 Mar 2017 14:18:07 -0700 (PDT)
Message-ID: <20170322.141807.1073258228876112696.davem@davemloft.net>
References: <1490149348.16816.135.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, glider@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752097AbdCVVSJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:18:09 -0400
In-Reply-To: <1490149348.16816.135.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Mar 2017 19:22:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Alexander reported a KMSAN splat caused by reads of uninitialized
> field (tb_id_in) from user provided struct fib_result_nl
> 
> It turns out nl_fib_input() sanity tests on user input is a bit
> wrong :
> 
> User can pretend nlh->nlmsg_len is big enough, but provide
> at sendmsg() time a too small buffer.
> 
> Reported-by: Alexander Potapenko <glider@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
