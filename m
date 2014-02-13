From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [CLEANUP] tcp: remove unused min_cwnd member of
 tcp_congestion_ops
Date: Thu, 13 Feb 2014 18:22:48 -0500 (EST)
Message-ID: <20140213.182248.2227273693708987389.davem@davemloft.net>
References: <1392212121-28574-1-git-send-email-stfomichev@yandex-team.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, edumazet@google.com, ncardwell@google.com,
	ycheng@google.com, netdev@vger.kernel.org
To: stfomichev@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbaBMXWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:22:51 -0500
In-Reply-To: <1392212121-28574-1-git-send-email-stfomichev@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislav Fomichev <stfomichev@yandex-team.ru>
Date: Wed, 12 Feb 2014 17:35:21 +0400

> Commit 684bad110757 "tcp: use PRR to reduce cwin in CWR state" removed all
> calls to min_cwnd, so we can safely remove it.
> Also, remove tcp_reno_min_cwnd because it was only used for min_cwnd.
> 
> Signed-off-by: Stanislav Fomichev <stfomichev@yandex-team.ru>

Applied, thanks.
