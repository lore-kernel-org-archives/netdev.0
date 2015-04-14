From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Tue, 14 Apr 2015 11:32:02 +0100
Message-ID: <20150414103202.GC14022@casper.infradead.org>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <20150410132205.GF23070@casper.infradead.org>
 <20150410200901.GB5968@salvia>
 <20150412.211421.1771298417488412635.davem@davemloft.net>
 <20150413201913.GD20275@acer.localdomain>
 <20150414090048.GA14022@casper.infradead.org>
 <20150414090559.GH22725@acer.localdomain>
 <20150414100846.GB14022@casper.infradead.org>
 <20150414101339.GC3004@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150414101339.GC3004@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/14/15 at 11:13am, Patrick McHardy wrote:
> I would actually expect them to use neither TC nor nft, so the most
> interesting number would be the impact if not used. Additionally I'd
> like to see the numbers for moving ingress to use the netfilter hook
> if it is actually used.
> 
> The costs of TC actions vs nft are actually not relevant in my
> opinion since we're not replacing anything.

Ingress filtering to implement distribtued packet filters is very
relevant for data centers. The times of no-policy data centers are
gone with multi tenancy.

Not all packets are routed so at least some of the filtering must
occur before prerouting. I'm afraid you can't take yourself out
of the fast path that easily ;-)

This is not a pledge specific to nft. I would like to see more
numbers in general. We are putting APIs and frameworks in place that
we can't remove afterwards without knowing how they really scale and
perform.
