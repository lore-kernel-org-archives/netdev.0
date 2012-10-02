From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: clean out braces / old code (found
 via checkpatch)
Date: Tue, 02 Oct 2012 14:46:03 -0400 (EDT)
Message-ID: <20121002.144603.513292881191877964.davem@davemloft.net>
References: <1349178105-28269-1-git-send-email-matthew@walster.org>
	<1349178105-28269-2-git-send-email-matthew@walster.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: matthew@walster.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912Ab2JBSqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 14:46:05 -0400
In-Reply-To: <1349178105-28269-2-git-send-email-matthew@walster.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: matthew@walster.org
Date: Tue,  2 Oct 2012 12:41:44 +0100

> From: Matthew Walster <matthew@walster.org>
> 
> Remove an old commented out piece of code.
> Remove an if(true) statement.
> Remove a set of braces that weren't strictly necessary.
> 
> All found by running checkpatch.pl against the code.
> 
> Signed-off-by: Matthew Walster <matthew@walster.org>

That comment and that unconditional if() are documentation.

Don't be an automaton and blindly make changes based upon
checkpatch.pl output.
