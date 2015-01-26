From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: fix rht_for_each_entry_safe() endless loop
Date: Mon, 26 Jan 2015 00:08:10 -0800 (PST)
Message-ID: <20150126.000810.1715444153546876457.davem@davemloft.net>
References: <1421838733-16495-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbbAZIIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 03:08:14 -0500
In-Reply-To: <1421838733-16495-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 21 Jan 2015 11:12:13 +0000

> "next" is not updated, causing an endless loop for buckets with more than
> one element.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
