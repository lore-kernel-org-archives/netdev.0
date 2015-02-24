From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 1/2] rhashtable: require max_shift if grow_decision
 defined
Date: Tue, 24 Feb 2015 22:49:15 +0000
Message-ID: <20150224224915.GB1199@casper.infradead.org>
References: <1424794259-30241-2-git-send-email-johunt@akamai.com>
 <20150224.131828.1632037288300527014.davem@davemloft.net>
 <54ECD57A.1080709@iogearbox.net>
 <20150224.163137.12835478467735127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, johunt@akamai.com, pablo@netfilter.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48302 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbbBXWtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 17:49:18 -0500
Content-Disposition: inline
In-Reply-To: <20150224.163137.12835478467735127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/15 at 04:31pm, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> > Fwiw, I believe this behavior came in as a regression via commit
> > c0c09bfdc415 ("rhashtable: avoid unnecessary wakeup for worker
> > queue").
> > Initially, if no max_shift was specified, we'd just expand further.
> >
> > I can take care of these above two fixups tomorrow, if you want.

Thanks!

> > I presume you want to route both via -net, or just the growth limit
> > issue via -net?
> 
> Let's fix as much crap as we can in -net.  I'm going to have to do
> a huge backport of all the rhashtables to -stable at some point
> too.

All fixes except 2-3 should only affect the post per bucket lock
era. The fixes tags should be correct but I'll double check. I can
take care of the backports if you like.
