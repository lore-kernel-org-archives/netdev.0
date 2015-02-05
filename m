From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/6 v2 net-next] rhashtable fixes
Date: Thu, 5 Feb 2015 08:47:37 +0000
Message-ID: <20150205084737.GA15549@casper.infradead.org>
References: <cover.1423097592.git.tgraf@suug.ch>
 <54D2D656.8060709@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54330 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755929AbbBEIrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:47:40 -0500
Content-Disposition: inline
In-Reply-To: <54D2D656.8060709@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/15 at 10:32am, Ying Xue wrote:
> After I applied the sires, it sounds like panic doesn't occur any more. But soft
> lockup still happens although the frequency of its reproduction is much lower
> than before. Please take a look at its relevant log:

Thanks for testing and the report. I had run your bind_netlink test
overnight on a 4 CPU VM. Anything particular that might help trigger it?
