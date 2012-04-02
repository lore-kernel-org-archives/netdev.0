From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: check the length of the data before dereferencing
 it
Date: Mon, 02 Apr 2012 05:59:14 +0200
Message-ID: <1333339154.2325.6623.camel@edumazet-glaptop>
References: <20120401.232942.1829187970291547571.davem@davemloft.net>
	 <CABa6K_HfWckb=sv7oQatv2ZJm3EKJE0mutQQ-OiddXiR6E7eHg@mail.gmail.com>
	 <1333338797.2325.6610.camel@edumazet-glaptop>
	 <20120401.235724.1615627410446519543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, kaber@trash.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120401.235724.1615627410446519543.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-04-01 at 23:57 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 02 Apr 2012 05:53:17 +0200
> 
> > On Mon, 2012-04-02 at 11:45 +0800, Changli Gao wrote:
> > 
> >> Thinking about a malformed tcp segment, which has no data but silly
> >> options, and whose last byte is neither TCPOPT_EOL or TCPOPT_NOP, we
> >> will try to dereference one byte over the boundary when parsing the
> >> options. I know we have skb_shared_info at the end and it won't cause
> >> any crash, but should we rely on this fact?
> >> 
> > 
> > No we cant rely on this, kmemcheck might barf on us.
> 
> Give me a break.

Sure. End of discussion.


