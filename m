From: David Miller <davem@davemloft.net>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 01:18:45 -0700 (PDT)
Message-ID: <20100423.011845.254684857.davem@davemloft.net>
References: <20100422.164425.171794554.davem@davemloft.net>
	<1272001478.7895.7545.camel@edumazet-laptop>
	<20100423.011328.107238355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hawk@diku.dk, paulmck@linux.vnet.ibm.com, kaber@trash.net,
	xiaosuo@gmail.com, hawk@comx.dk, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100423.011328.107238355.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Fri, 23 Apr 2010 01:13:28 -0700 (PDT)

> I really can't see what might cause this behavior then.

This all reminds me of the namespace bug we dealt with
a month or two ago.

Jesper, you don't happen to be using network namespaces are you?
Because if so, the following might be your cure.

commit 5b3501faa8741d50617ce4191c20061c6ef36cb3
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Mon Feb 8 11:16:56 2010 -0800

    netfilter: nf_conntrack: per netns nf_conntrack_cachep
