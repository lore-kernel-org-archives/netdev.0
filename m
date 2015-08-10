From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add explicit logging and stat for
 neighbour table overflow
Date: Mon, 10 Aug 2015 13:46:45 -0700 (PDT)
Message-ID: <20150810.134645.320097321290649615.davem@davemloft.net>
References: <20150807181038.2A32029003CC@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932553AbbHJUqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 16:46:46 -0400
In-Reply-To: <20150807181038.2A32029003CC@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Fri,  7 Aug 2015 11:10:37 -0700 (PDT)

> From: Rick Jones <rick.jones2@hp.com>
> 
> Add an explicit neighbour table overflow message (ratelimited) and
> statistic to make diagnosing neighbour table overflows tractable in
> the wild.
> 
> Diagnosing a neighbour table overflow can be quite difficult in the wild
> because there is no explicit dmesg logged.  Callers to neighbour code
> seem to use net_dbg_ratelimit when the neighbour call fails which means
> the "base message" is not emitted and the callback suppressed messages
> from the ratelimiting can end-up juxtaposed with unrelated messages.
> Further, a forced garbage collection will increment a stat on each call
> whether it was successful in freeing-up a table entry or not, so that
> statistic is only a hint.  So, add a net_info_ratelimited message and
> explicit statistic to the neighbour code.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Looks fine, applied, thanks Rick.
