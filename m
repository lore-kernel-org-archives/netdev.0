From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Sun, 3 Nov 2002 14:08:49 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211031407270.27836-100000@netcore.fi>
References: <1036328414.1048.3.camel@arwen>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?= =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>,
   <linux-kernel@vger.kernel.org>, Netdev <netdev@oss.sgi.com>,
   Netfilter Devel <netfilter-devel@lists.netfilter.org>,
   "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andras Kis-Szabo <kisza@securityaudit.hu>
In-Reply-To: <1036328414.1048.3.camel@arwen>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 3 Nov 2002, Andras Kis-Szabo wrote:
> >  - export route6_me_harder() as ip6_route_harder() and
> >    use it from net/ipv6/netfilter/ip6_queue.c.
> Opsz!
> At the extension parser code we got that decision that we should use
> our own parser in the Netfilter code! (And we should not to trust in the
> kernel.)
> This patch removes one function from the Netfilter code and forces the
> Netfilter to use a similar function from the kernel's one!

And why is that a problem?

If there is a problem in main kernel code, it should fixed.  If the 
netfilter version is better, the main kernel code should be changed.

Are there specific reasons to keep them separate?

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
