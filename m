From: Andras Kis-Szabo <kisza@securityaudit.hu>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Sun, 03 Nov 2002 14:00:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1036328414.1048.3.camel@arwen>
References: <20021103.115427.104445233.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>,
   Netfilter Devel <netfilter-devel@lists.netfilter.org>,
   "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <20021103.115427.104445233.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?=
 =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

>  - export route6_me_harder() as ip6_route_harder() and
>    use it from net/ipv6/netfilter/ip6_queue.c.
Opsz!
At the extension parser code we got that decision that we should use
our own parser in the Netfilter code! (And we should not to trust in the
kernel.)
This patch removes one function from the Netfilter code and forces the
Netfilter to use a similar function from the kernel's one!

Regards,

	kisza
 
-- 
    Andras Kis-Szabo       Security Development, Design and Audit
-------------------------/        Zorp, NetFilter and IPv6
 kisza@SecurityAudit.hu /------------------------------------------->
