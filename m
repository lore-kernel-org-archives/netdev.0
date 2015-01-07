From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 2/7] rhashtable: introduce
 rhashtable_wakeup_worker helper function
Date: Wed, 7 Jan 2015 09:34:44 +0000
Message-ID: <20150107093444.GH21820@casper.infradead.org>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
 <1420609318-3261-3-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60947 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbbAGJer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 04:34:47 -0500
Content-Disposition: inline
In-Reply-To: <1420609318-3261-3-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 01:41pm, Ying Xue wrote:
> Introduce rhashtable_wakeup_worker() helper function to reduce
> duplicated code where to wake up worker.
> 
> By the way, as long as the both "future_tbl" and "tbl" bucket table
> pointers point to the same bucket array, we should try to wake up
> the resizing worker thread, otherwise, it indicates the work of
> resizing hash table is not finished yet. However, currently we will
> wake up the worker thread only when the two pointers point to
> different bucket array. Obviously this is wrong. So, the issue is
> also fixed as well in the patch.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>

Acked-by: Thomas Graf <tgraf@suug.ch>
