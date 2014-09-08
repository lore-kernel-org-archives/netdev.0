From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sunvnet - add missing rmb() for sunvnet driver
Date: Mon, 08 Sep 2014 14:07:34 -0700 (PDT)
Message-ID: <20140908.140734.753711817014352432.davem@davemloft.net>
References: <1410207781.24238.5.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173AbaIHVHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:07:37 -0400
In-Reply-To: <1410207781.24238.5.camel@phoenix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 08 Sep 2014 16:23:01 -0400

> The sunvnet driver does not have an rmb() in the ring consumer corresponding
> to the wmb() in the producer. According to Documentation/memory-barriers.txt:
 ...
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

I'll apply this, but I just remembered that the kernel always runs in
the TSO memory model these days and thus all the memory barriers are
NOPs.
