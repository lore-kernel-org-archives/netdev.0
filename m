From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Wed, 23 Aug 2017 09:34:20 +1000
Message-ID: <20170823093420.4b64fa55@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
produced this warning:

net/ipv6/route.c: In function 'rt6_check':
net/ipv6/route.c:1294:43: warning: 'rt_cookie' may be used uninitialized in this function [-Wmaybe-uninitialized]
  if (!rt6_get_cookie_safe(rt, &rt_cookie) || rt_cookie != cookie)
                                           ^

Introduced by commit

  c5cff8561d2d ("ipv6: add rcu grace period before freeing fib6_node")

-- 
Cheers,
Stephen Rothwell
