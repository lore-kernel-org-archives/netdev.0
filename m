From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: Add support for adaptive interrupt
 coalescing
Date: Thu, 08 May 2014 13:03:33 -0400 (EDT)
Message-ID: <20140508.130333.2263967033333936453.davem@davemloft.net>
References: <1399386262-20769-1-git-send-email-_govind@gmx.com>
	<20140507.170043.896249393177676627.davem@davemloft.net>
	<alpine.LNX.2.03.1405081126320.1536@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com, neepatel@cisco.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbaEHRDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 13:03:37 -0400
In-Reply-To: <alpine.LNX.2.03.1405081126320.1536@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Thu, 8 May 2014 11:43:03 +0530 (IST)

> The idea was to get time delta in usec, to measure the pkt rate. We
> want to make damping of coal timer more aggressive. I guess we can use
> ktime_get() instead of hrtimers.

Yes, just use ktime_get().
