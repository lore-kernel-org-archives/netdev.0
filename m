From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 0/7] Involve rhashtable_lookup_insert routine
Date: Wed, 7 Jan 2015 09:54:47 +0000
Message-ID: <20150107095447.GL21820@casper.infradead.org>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:32813 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbbAGJyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 04:54:49 -0500
Content-Disposition: inline
In-Reply-To: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 01:41pm, Ying Xue wrote:
> The series aims to involve rhashtable_lookup_insert() to guarantee
> that the process of lookup and insertion of an object from/into hash
> table is finished atomically, allowing rhashtable's users not to
> introduce an extra lock during search and insertion. For example,
> tipc socket is the first user benefiting from this enhancement. 
> 
> v2 changes:

Thanks, this looks excellent. I think patch 6/7 can be dropped,
otherwise this looks ready to go. I acked all other changes.
