From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: fix crash at module unload
Date: Thu, 10 May 2012 23:12:20 -0400 (EDT)
Message-ID: <20120510.231220.1940765034292337639.davem@davemloft.net>
References: <1336591268.12504.62.camel@edumazet-glaptop>
	<874nrpyrp1.fsf@xmission.com>
	<1336606191.12504.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932423Ab2EKDMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:12:22 -0400
In-Reply-To: <1336606191.12504.97.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 May 2012 01:29:51 +0200

> [PATCH v2] pktgen: fix crash at module unload
> 
> commit 7d3d43dab4e9 (net: In unregister_netdevice_notifier unregister
> the netdevices.) makes pktgen crashing at module unload.
...
> Hold the pktgen_thread_lock while splicing pktgen_threads, and test
> pktgen_exiting in pktgen_device_event() to make unload faster.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>

Applied and queued up for -stable.
