From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during
 softnet overflow
Date: Tue, 23 Apr 2013 18:41:40 -0400 (EDT)
Message-ID: <20130423.184140.2020239496583590253.davem@davemloft.net>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	<1366749094-5982-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755896Ab3DWWll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 18:41:41 -0400
In-Reply-To: <1366749094-5982-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 23 Apr 2013 16:31:34 -0400

> - disable the kconfig option by default, as it is workload specific.

If this logic only kicks in during overload, I see no reason why we
shouldn't have this protection enabled unconditionally, all the time.

Does it hurt performance under normal workloads?

If the new logic is controlled by overload thresholds then it should
have no impact whatsoever in non-overload scenerios.
