From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: fix an oops in rt6_device_match()
Date: Mon, 13 Sep 2004 09:49:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913.094950.47321151.yoshfuji@linux-ipv6.org>
References: <20040911.201029.21582458.yoshfuji@linux-ipv6.org>
	<20040912163216.7f49673a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040912163216.7f49673a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040912163216.7f49673a.davem@davemloft.net> (at Sun, 12 Sep 2004 16:32:16 -0700), "David S. Miller" <davem@davemloft.net> says:

> > Well, rt->rt6i_idev is always set if it is dynamically allocated.
> > However, when we hit ip6_null_entry here, its rt6i_idev is NULL.
> > This patch is minimum fix to avoid the oops for now.
> > 
> > Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> 
> Ok, as long as we fix this more cleanly eventually.

Thanks.
I'll revisit when we introduce more users (per-interface stats.).

--yoshfuji
