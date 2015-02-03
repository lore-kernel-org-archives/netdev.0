From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/6 net-next] rhashtable fixes
Date: Tue, 3 Feb 2015 17:21:13 +0000
Message-ID: <20150203172113.GC25410@casper.infradead.org>
References: <cover.1422576760.git.tgraf@suug.ch>
 <54CB4A95.9060000@windriver.com>
 <20150130092911.GA2313@casper.infradead.org>
 <54CB5563.9080000@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37971 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756087AbbBCRVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 12:21:16 -0500
Content-Disposition: inline
In-Reply-To: <54CB5563.9080000@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/15 at 05:56pm, Ying Xue wrote:
> On 01/30/2015 05:29 PM, Thomas Graf wrote:
> > Right, I see the same soft lockup. Interestingly I cannot trigger it
> > with the rht test code. I can only trigger it with your Netlink socket
> > creation stress test. It is definitely related to the deferred worker,
> > when I disable growing, then the bug disappears.
> 
> Yes, when I disable expansion, the soft lockup also disappears too.

I have found the last remaining race and can now run your test
program successfully in an endless loop.

I will resubmit a v2 of this series.
