From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Sun, 23 Feb 2003 01:18:16 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030223.011816.108201183.davem@redhat.com>
References: <20021103.115427.104445233.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, kuznet@ms2.inr.ac.ru,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021103.115427.104445233.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Sun, 03 Nov 2002 11:54:27 +0900 (JST)
   
   This patch cleans up functions in ipv6 stack:
   
    - export route6_me_harder() as ip6_route_harder() and
      use it from net/ipv6/netfilter/ip6_queue.c.
    - make ip6_addr_prefix() to generate prefix of given address and
      prefix length, instead of doing "ipv6_copy_addr() then
      ipv6_wash_prefix()."
   
Please change new name to ip6_route_me_harder().  When one
says "something me harder" is has amusing implications when
heard by most english speakers and I'd like to keep this :-)

I will apply this patch once you make the change.  Would you
like me to add it to 2.4.x as well?

We really need to revisit USAGI patch backlog.  I have and will apply
privacy extension 2.5.x patch you sent.  For all the others please
feel free to "patch bomb" me :-) Please indicate with each patch
whether the it is desired in 2.4.x as well.

If you wish to concentrate on ipv6 ipsec first, that is ok too. :-)
