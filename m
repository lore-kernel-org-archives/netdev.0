From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Fri, 10 Oct 2014 00:36:28 -0400 (EDT)
Message-ID: <20141010.003628.646817757614430018.davem@davemloft.net>
References: <20141006.152526.965519223260573233.davem@davemloft.net>
	<20141006193111.GE24721@oracle.com>
	<EB9A1CD1-6E1D-409C-89CB-95CC9A5AFC1D@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: Raghuram.Kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaJJEga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 00:36:30 -0400
In-Reply-To: <EB9A1CD1-6E1D-409C-89CB-95CC9A5AFC1D@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Date: Thu, 9 Oct 2014 18:10:24 -0700

> Lock less Tx and Rx implementation is very nice, but requires to the
> code path to single threaded to achieve it.

I would like to know how you believe the Linux LLTX "lockless TX"
facility works.

It's not truly lockless, it just turns off the generic networking TX
path per-queue spinlock and puts the full burdon on the driver.  It's
just moving the locking from one place to another, not eliminating it.
