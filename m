From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same
 Port Number (IPV6_V6ONLY Support)
Date: Thu, 03 Oct 2002 01:29:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.012904.75241727.davem@redhat.com>
References: <20021003.121350.119660876.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021003.121350.119660876.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Thu, 03 Oct 2002 12:13:50 +0900 (JST)

   Linux IPv6 stack provides the ability for IPv6 applications to
   interoperate with IPv4 applications.  Port space for TCP (or UDP) is
   shared by IPv6 and IPv4.  This conforms to RFC2553.
   However, some kind of applications may want to restrict their use of
   an IPv6 socket to IPv6 communication only.  IPV6_V6ONLY socket option is
   defined for such applications in RFC2553bis, which is successor of RFC2553.  

I really wish BSD socket features did not get standardized
in RFC's, we must live with their mistakes.

For example, this IPV6_V6ONLY socket option is flawed.  What we
really need is a generic socket option which says "my family only"

There is nothing ipv6 specific about such a socket attribute.

So please, create instead "SO_ONEFAMILY" or similar generic
socket option.

I still need to review the rest of the patch for functional
correctness.  This is probably the most complex area of the
socket identity code in TCP/UDP :-)
