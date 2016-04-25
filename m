From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] codel: make it reuseable beyond qdiscs
Date: Mon, 25 Apr 2016 16:45:06 -0400 (EDT)
Message-ID: <20160425.164506.1398835425196909640.davem@davemloft.net>
References: <1461327359-21646-1-git-send-email-michal.kazior@tieto.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: michal.kazior@tieto.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964779AbcDYUpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:45:08 -0400
In-Reply-To: <1461327359-21646-1-git-send-email-michal.kazior@tieto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kazior <michal.kazior@tieto.com>
Date: Fri, 22 Apr 2016 14:15:57 +0200

> There's an ongoing effort in fixing wireless
> bufferbloat. As part of that fq_codel is being
> ported into mac80211. To prevent code duplication
> codel.h needs to be slightly modified before it
> can be used in mac80211 (or other drivers FWIW).
> 
> For more background please see:
> 
>   https://www.spinics.net/lists/linux-wireless/msg149976.html

Series applied, but I reserve the right the revert this if the
indirect functions calling this introduces causes performance
regressions.

Thanks.
