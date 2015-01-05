From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: convert tipc reference table to use
 generic rhashtable
Date: Sun, 04 Jan 2015 23:43:09 -0500 (EST)
Message-ID: <20150104.234309.1238789079887665107.davem@davemloft.net>
References: <1420356862-7523-1-git-send-email-ying.xue@windriver.com>
	<20150104095320.GB15305@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, tipc-discussion@lists.sourceforge.net
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbbAEEnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 23:43:18 -0500
In-Reply-To: <20150104095320.GB15305@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Sun, 4 Jan 2015 09:53:20 +0000

> As a further optimization, you could add a new atomic function
> rhashtable_lookup_and_insert() which holds the per bucket lock during
> lookup and use that instead. This would allow you to get rid of the
> mutex alltogether.

This would definitely be a better implementation in my opinion.
