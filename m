From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] rhashtable: unnecessary to use delayed work
Date: Tue, 13 Jan 2015 11:26:12 +0000
Message-ID: <20150113112612.GI20387@casper.infradead.org>
References: <1421139645-1588-1-git-send-email-ying.xue@windriver.com>
 <20150113093550.GG20387@casper.infradead.org>
 <54B4EA06.8010507@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51296 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbbAML0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 06:26:14 -0500
Content-Disposition: inline
In-Reply-To: <54B4EA06.8010507@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/15 at 05:48pm, Ying Xue wrote:
> On 01/13/2015 05:35 PM, Thomas Graf wrote:
> > If you agree we can explain this shortly in the commit message and add:
> > Fixes: 97defe1 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> 
> OK, I will deliver the next version.
> 
> By the way, I think we should check the following condition before call
> cancel_work_sync(), otherwise, we may cancel an uninitialized work.
> 
> (ht->p.grow_decision || ht->p.shrink_decision)
> 
> What do you think?

+1
