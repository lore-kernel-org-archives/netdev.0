From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Tue, 14 Apr 2015 11:13:39 +0100
Message-ID: <20150414101339.GC3004@acer.localdomain>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <20150410132205.GF23070@casper.infradead.org>
 <20150410200901.GB5968@salvia>
 <20150412.211421.1771298417488412635.davem@davemloft.net>
 <20150413201913.GD20275@acer.localdomain>
 <20150414090048.GA14022@casper.infradead.org>
 <20150414090559.GH22725@acer.localdomain>
 <20150414100846.GB14022@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45487 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408AbbDNKNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 06:13:45 -0400
Content-Disposition: inline
In-Reply-To: <20150414100846.GB14022@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.04, Thomas Graf wrote:
> On 04/14/15 at 10:06am, Patrick McHardy wrote:
> > On 14.04, Thomas Graf wrote:
> > > On 04/13/15 at 09:19pm, Patrick McHardy wrote:
> > > > Now the advantages of being able to use nft. First, the obvious
> > > > one is that we have a nice userspace tool, a well defined
> > > > grammar, and that people would be able to use the same tool for
> > > > very similar tasks. nftables in the kernel is almost completely
> > > > lockless, we support way more possibilites already and we won't
> > > > have to add new special case TC actions anymore. Look at the
> > > > connmark action for example. It can set a value. How long until
> > > > someone wants to use a bitmask? We support all operations
> > > > (assignment, bit operations) for all types, we have sets for fast
> > > > lookups, maps for associating values quickly, we have a nice and
> > > > readable syntax and full translation back to the readable
> > > > representation and much more.
> > > 
> > > *cough* Performance numbers? *cough* ;-)
> > 
> > I'm just arguing, not implementing :)
> 
> OK ;-) Seriously though, we need to start putting emphasis on
> numbers as well. We are supposed to run data centers with all of
> this, we can't just horse around for fun ;-)

I would actually expect them to use neither TC nor nft, so the most
interesting number would be the impact if not used. Additionally I'd
like to see the numbers for moving ingress to use the netfilter hook
if it is actually used.

The costs of TC actions vs nft are actually not relevant in my
opinion since we're not replacing anything.
