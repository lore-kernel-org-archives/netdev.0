From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] rhashtable: Annotate RCU locking of
 walkers
Date: Mon, 16 Mar 2015 16:24:47 -0400 (EDT)
Message-ID: <20150316.162447.1982455483366854663.davem@davemloft.net>
References: <cover.1426494808.git.tgraf@suug.ch>
	<cover.1426494808.git.tgraf@suug.ch>
	<a04b70711ea826e6fa2ddf14369768ead310f59d.1426494808.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119AbbCPUYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:24:49 -0400
In-Reply-To: <a04b70711ea826e6fa2ddf14369768ead310f59d.1426494808.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 16 Mar 2015 10:42:27 +0100

> Fixes the following sparse warnings:
> 
> lib/rhashtable.c:767:5: warning: context imbalance in 'rhashtable_walk_start' - wrong count at exit
> lib/rhashtable.c:849:6: warning: context imbalance in 'rhashtable_walk_stop' - unexpected unlock
> 
> Fixes: f2dba9c6ff0d ("rhashtable: Introduce rhashtable_walk_*")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
