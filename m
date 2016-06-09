From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] net: vrf: call
 netdev_lockdep_set_classes()
Date: Thu, 09 Jun 2016 00:03:16 -0700 (PDT)
Message-ID: <20160609.000316.1456143545684135431.davem@davemloft.net>
References: <1465430127-22993-1-git-send-email-edumazet@google.com>
	<1465430127-22993-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161015AbcFIHDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 03:03:17 -0400
In-Reply-To: <1465430127-22993-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed,  8 Jun 2016 16:55:25 -0700

> In case a qdisc is used on a vrf device, we need to use different
> lockdep classes to avoid false positives.
> 
> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
