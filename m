From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] ipv6: fix typo in fib6_net_exit()
Date: Sat, 9 Sep 2017 01:09:57 +0200
Message-ID: <20170908230957.GA9580@bistromath.localdomain>
References: <204659713af1979c26b8defb2b52e1668b4e5aad.1504859062.git.sd@queasysnail.net>
 <1504893592.15310.80.camel@edumazet-glaptop3.roam.corp.google.com>
 <1504910927.15310.105.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41888 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753166AbdIHXKB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 19:10:01 -0400
Content-Disposition: inline
In-Reply-To: <1504910927.15310.105.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-09-08, 15:48:47 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> IPv6 FIB should use FIB6_TABLE_HASHSZ, not FIB_TABLE_HASHSZ.
> 
> Fixes: ba1cc08d9488 ("ipv6: fix memory leak with multiple tables during netns destruction")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Ouch, yes :(
Thanks for the fix.

Acked-by: Sabrina Dubroca <sd@queasysnail.net>

-- 
Sabrina
