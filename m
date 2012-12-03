From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Mon, 03 Dec 2012 17:06:36 -0500 (EST)
Message-ID: <20121203.170636.1325623456787407245.davem@davemloft.net>
References: <1354538763-2678-1-git-send-email-dries.dewinter@gmail.com>
	<20121203.141128.206409637987621093.davem@davemloft.net>
	<CA+e04fjWMDE9xEApysFRprZDBdM3Ya2RHrxtoau7i+fxzGT8CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: dries.dewinter@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+e04fjWMDE9xEApysFRprZDBdM3Ya2RHrxtoau7i+fxzGT8CQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dries De Winter <dries.dewinter@gmail.com>
Date: Mon, 3 Dec 2012 22:31:51 +0100

> Not fixing this means that skb->mark is unavailable for use on ICMPv6
> packets because it will inevitably put those packets on the wrong
> interface.

Maybe this suggests that a better fix is to simply explicitly check
for protocol ICMPV6 in ip6_route_me_harder().
