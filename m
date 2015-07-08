From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 net-next] tcp: reducing lost retransmits in recovery
Date: Wed, 08 Jul 2015 13:30:03 -0700 (PDT)
Message-ID: <20150708.133003.612921512265899727.davem@davemloft.net>
References: <1435785075-20600-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755142AbbGHUaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 16:30:06 -0400
In-Reply-To: <1435785075-20600-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed,  1 Jul 2015 14:11:13 -0700

> This patch series reduces lost retransmits in recovery, in particular
> when dealing with traffic policers. The main problem is that
> slow start in recovery under policing can cause massive lost and
> retransmit storms: any excess sending rate turns into drops. The
> solution is to avoid doing slow start when lost retransmit is
> detected and use packet conservation instead.
> 
> On networks with traffic policers the patches have lowered the
> TCP loss rates by ~20% from Google servers without latency regressions.

Looks great, series applied to net-next.
