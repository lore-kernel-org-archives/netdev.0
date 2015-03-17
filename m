From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 nf-next 1/6] net: untangle ip_fragment and bridge
 netfilter
Date: Tue, 17 Mar 2015 17:38:36 -0400 (EDT)
Message-ID: <20150317.173836.1289493333858576885.davem@davemloft.net>
References: <20150317101152.GB26394@breakpoint.cc>
	<20150317.131250.1794140944101735383.davem@davemloft.net>
	<20150317204028.GC26394@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, azhou@nicira.com
To: fw@strlen.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150317204028.GC26394@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Tue, 17 Mar 2015 21:40:28 +0100

> Ideally, the bridge would re-create the original fragments it received
> on 1:1 basis to make it fully transparent, and to make the bridge behave
> as if it would not do the defrag layering violations in the first place.

And we have infrastructure to do exactly this, via GRO.
