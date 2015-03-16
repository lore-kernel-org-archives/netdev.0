From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] rhashtable: Avoid calculating hash again
 to unlock
Date: Mon, 16 Mar 2015 16:22:02 -0400 (EDT)
Message-ID: <20150316.162202.2166849044626317059.davem@davemloft.net>
References: <cover.1426494808.git.tgraf@suug.ch>
	<cover.1426494808.git.tgraf@suug.ch>
	<e66c2872d3182c2df12f5657903f19e8ffc1f0f0.1426494808.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985AbbCPUWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:22:04 -0400
In-Reply-To: <e66c2872d3182c2df12f5657903f19e8ffc1f0f0.1426494808.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 16 Mar 2015 10:42:26 +0100

> Caching the lock pointer avoids having to hash on the object
> again to unlock the bucket locks.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I'd like to hold off on this.

My understanding is that Herbert plans to expand the table size
synchonously during insert in emergency situations, and in that regime
some of these optimization won't be valid.
