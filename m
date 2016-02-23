From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: convert cached rtt from usec to jiffies when
 feeding initial rto
Date: Tue, 23 Feb 2016 18:33:11 -0500 (EST)
Message-ID: <20160223.183311.990990388575541765.davem@davemloft.net>
References: <20160221071239.9977.45366.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbcBXAIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 19:08:12 -0500
In-Reply-To: <20160221071239.9977.45366.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Sun, 21 Feb 2016 10:12:39 +0300

> Currently it's converted into msecs, thus HZ=1000 intact.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 740b0f1841f6 ("tcp: switch rtt estimations to usec resolution")

Applied and queued up for -stable, thanks.
