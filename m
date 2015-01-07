From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 5/7] rhashtable: avoid unnecessary wakeup for
 worker queue
Date: Wed, 7 Jan 2015 09:50:13 +0000
Message-ID: <20150107095013.GJ21820@casper.infradead.org>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
 <1420609318-3261-6-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:32785 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756711AbbAGJuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 04:50:14 -0500
Content-Disposition: inline
In-Reply-To: <1420609318-3261-6-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 01:41pm, Ying Xue wrote:
> Move condition statements of verifying whether hash table size exceeds
> its maximum threshold or reaches its minimum threshold from resizing
> functions to resizing decision functions, avoiding unnecessary wakeup
> for worker queue thread.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>

Good optimization, thanks!

Acked-by: Thomas Graf <tgraf@suug.ch>

Can you do a follow-up patch and add a note in rhashtable.h to
indicate the implementation of the grow and shrink decision function
must enforce min/max shift?
