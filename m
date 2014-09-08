From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hp100: Convert the normal skb free path to
 dev_consume_skb_any()
Date: Mon, 08 Sep 2014 15:40:42 -0700 (PDT)
Message-ID: <20140908.154042.699816127384230272.davem@davemloft.net>
References: <20140908153133.103882900309@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, perex@perex.cz
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754898AbaIHWkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 18:40:43 -0400
In-Reply-To: <20140908153133.103882900309@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Mon,  8 Sep 2014 08:31:32 -0700 (PDT)

> From: Rick Jones <rick.jones2@hp.com>
> 
> A bit of floor sweeping in a dusty old corner.  Convert the "normal"
> skb free calls to dev_consume_skb_any() so packet drop tracing will
> be more sane.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks Rick.
