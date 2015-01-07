From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 4/7] rhashtable: future table needs to be
 traversed when remove an object
Date: Wed, 7 Jan 2015 09:39:00 +0000
Message-ID: <20150107093900.GI21820@casper.infradead.org>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
 <1420609318-3261-5-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60981 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbbAGJjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 04:39:01 -0500
Content-Disposition: inline
In-Reply-To: <1420609318-3261-5-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 01:41pm, Ying Xue wrote:
> When remove an object from hash table, we currently only traverse old
> bucket table to check whether the object exists. If the object is not
> found in it, we will try again. But in the second search loop, we still
> search the object from the old table instead of future table. As a
> result, the object may be not removed from hash table especially when
> resizing is currently in progress and the object is just saved in the
> future table.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>

Nice catch!
Acked-by: Thomas Graf <tgraf@suug.ch>
