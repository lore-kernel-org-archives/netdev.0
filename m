From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Tue, 14 Apr 2015 10:00:48 +0100
Message-ID: <20150414090048.GA14022@casper.infradead.org>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <20150410132205.GF23070@casper.infradead.org>
 <20150410200901.GB5968@salvia>
 <20150412.211421.1771298417488412635.davem@davemloft.net>
 <20150413201913.GD20275@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150413201913.GD20275@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/13/15 at 09:19pm, Patrick McHardy wrote:
> Now the advantages of being able to use nft. First, the obvious
> one is that we have a nice userspace tool, a well defined
> grammar, and that people would be able to use the same tool for
> very similar tasks. nftables in the kernel is almost completely
> lockless, we support way more possibilites already and we won't
> have to add new special case TC actions anymore. Look at the
> connmark action for example. It can set a value. How long until
> someone wants to use a bitmask? We support all operations
> (assignment, bit operations) for all types, we have sets for fast
> lookups, maps for associating values quickly, we have a nice and
> readable syntax and full translation back to the readable
> representation and much more.

*cough* Performance numbers? *cough* ;-)
