From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Use dev_consume_skb_any() in the
 non-drop path
Date: Fri, 29 Aug 2014 20:37:15 -0700 (PDT)
Message-ID: <20140829.203715.926250452196304335.davem@davemloft.net>
References: <20140828155316.5AE982900409@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbaH3DhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:37:16 -0400
In-Reply-To: <20140828155316.5AE982900409@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Thu, 28 Aug 2014 08:53:16 -0700 (PDT)

> From: Rick Jones <rick.jones2@hp.com>
> 
> The be2net driver was still using dev_kfree_skb_any() in a "normal"
> skb freeing path.  This rather clutters perf top -G -e skb_kfree_skb
> profiling.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks Rick.
