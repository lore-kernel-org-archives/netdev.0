From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: r8169: panic on 2.6.11
Date: Fri, 04 Mar 2005 16:37:39 -0500
Message-ID: <4228D523.2070703@pobox.com>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050304132804.270cf05b@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I was intentionally over stressing r8169 without NAPI to test out
> an alternative version of netif_rx, and discovered the following bug.
> Looks like a problem in r8169. I was using pktgen to overwhelm the r8169
> from a fast machine.

Does 2.6.10 fail in a similar manner?


> eth0: Too much work at interrupt!
> eth0: Too much work at interrupt!
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:91!

Any idea what this BUG actually means?  Since it's in skb_over_panic(), 
a function designed to do nothing but BUG(), that doesn't tell us a 
whole lot about the callsite.

	Jeff
