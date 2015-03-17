From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 nf-next 1/6] net: untangle ip_fragment and bridge
 netfilter
Date: Tue, 17 Mar 2015 13:12:50 -0400 (EDT)
Message-ID: <20150317.131250.1794140944101735383.davem@davemloft.net>
References: <20150316225545.GA4454@salvia>
	<20150317.004224.595812379252826772.davem@davemloft.net>
	<20150317101152.GB26394@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, azhou@nicira.com
To: fw@strlen.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150317101152.GB26394@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Tue, 17 Mar 2015 11:11:52 +0100

> And doing route lookups will break things for some people, we have zero
> guarantee that a bridge has the needed routing information,
> its valid to not even configure a default gateway on a bridge.

Then without a proper route you absolutely cannot choose an
appropriate MTU from which to perform fragmentation.

Just accept that basic fact.
