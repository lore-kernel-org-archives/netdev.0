From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: check the length of the data before dereferencing
 it
Date: Sun, 01 Apr 2012 23:55:33 -0400 (EDT)
Message-ID: <20120401.235533.147910953675133023.davem@davemloft.net>
References: <1333336773.2325.6531.camel@edumazet-glaptop>
	<20120401.232942.1829187970291547571.davem@davemloft.net>
	<1333338345.2325.6591.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, kaber@trash.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1333338345.2325.6591.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Apr 2012 05:45:45 +0200

> Usually not a problem since we have many bytes after our head.

We always have bytes after the head, it's guarenteed, and whether it's
garbage bytes or skb_shared_info() it simply doesn't matter.
