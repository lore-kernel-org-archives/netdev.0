From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rhashtable: fix rht_for_each_entry_safe() endless loop
Date: Wed, 21 Jan 2015 11:43:20 +0000
Message-ID: <20150121114320.GU20315@casper.infradead.org>
References: <1421838733-16495-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36219 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbbAULnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 06:43:21 -0500
Content-Disposition: inline
In-Reply-To: <1421838733-16495-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/15 at 11:12am, Patrick McHardy wrote:
> "next" is not updated, causing an endless loop for buckets with more than
> one element.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Fixes: 88d6ed15acff ("rhashtable: Convert bucket iterators to take table and index")

Acked-by: Thomas Graf <tgraf@suug.ch>

Dave: This only affects net-next.
