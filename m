From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fq: split out backlog update logic
Date: Thu, 28 Apr 2016 17:04:05 -0400 (EDT)
Message-ID: <20160428.170405.777126222000837373.davem@davemloft.net>
References: <1461754753-18051-1-git-send-email-michal.kazior@tieto.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: michal.kazior@tieto.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbcD1VEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:04:07 -0400
In-Reply-To: <1461754753-18051-1-git-send-email-michal.kazior@tieto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kazior <michal.kazior@tieto.com>
Date: Wed, 27 Apr 2016 12:59:13 +0200

> mac80211 (which will be the first user of the
> fq.h) recently started to support software A-MSDU
> aggregation. It glues skbuffs together into a
> single one so the backlog accounting needs to be
> more fine-grained.
> 
> To avoid backlog sorting logic duplication split
> it up for re-use.
> 
> Signed-off-by: Michal Kazior <michal.kazior@tieto.com>

Applied, thanks.
