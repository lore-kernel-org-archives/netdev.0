From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/11] net: various udp/tcp changes
Date: Mon, 04 Apr 2016 22:12:13 -0400 (EDT)
Message-ID: <20160404.221213.652373243813091753.davem@davemloft.net>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	tom@herbertland.com, willemb@google.com, ncardwell@google.com,
	maze@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757155AbcDECNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 22:13:22 -0400
In-Reply-To: <1459525942-30399-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri,  1 Apr 2016 08:52:11 -0700

> First round of patches for linux-4.7

Nice series, applied.

I honestly think we can elide socket memory accounting for
(non-data-bearing) SYNACKs if that's showing up in the perf
profiles for SYN attacks.
