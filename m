From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: check the length of the data before dereferencing
 it
Date: Mon, 02 Apr 2012 05:58:25 +0200
Message-ID: <1333339105.2325.6622.camel@edumazet-glaptop>
References: <1333336773.2325.6531.camel@edumazet-glaptop>
	 <20120401.232942.1829187970291547571.davem@davemloft.net>
	 <1333338345.2325.6591.camel@edumazet-glaptop>
	 <20120401.235533.147910953675133023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, kaber@trash.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120401.235533.147910953675133023.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-04-01 at 23:55 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 02 Apr 2012 05:45:45 +0200
> 
> > Usually not a problem since we have many bytes after our head.
> 
> We always have bytes after the head, it's guarenteed, and whether it's
> garbage bytes or skb_shared_info() it simply doesn't matter.

Then you have to add a kmemcheck_something() to make this clear and
avoid possible warnings.




