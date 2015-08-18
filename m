From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/21] net: Convert drivers to IFF_NO_QUEUE and cleanup
 afterwards
Date: Tue, 18 Aug 2015 11:56:55 -0700 (PDT)
Message-ID: <20150818.115655.2274250362160199332.davem@davemloft.net>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbbHRS44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 14:56:56 -0400
In-Reply-To: <1439886649-24166-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Tue, 18 Aug 2015 10:30:28 +0200

> This series converts in-tree users away from the old and deprecated
> 'tx_queue_len = 0' idiom, adds a warning to notify out-of-tree driver
> maintainers that there is need for action on their behalf and finally drops any
> workarounds in scheduling algorithm implementations.

I've applied this series, but please address the removal of trivial qdiscs issue
that Eric Dumazet brought up.

Thanks.
