From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Thu, 03 Apr 2008 13:48:13 -0700 (PDT)
Message-ID: <20080403.134813.201577998.davem@davemloft.net>
References: <1206752049.22530.105.camel@johannes.berg>
	<20080328.180631.91055366.davem@davemloft.net>
	<1206784948.22530.128.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40597
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753217AbYDCUsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 16:48:13 -0400
In-Reply-To: <1206784948.22530.128.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 29 Mar 2008 11:02:28 +0100

> However, as I just tried to explain, cancel_work_sync() _is_ safe to run
> while holding the RTNL because it doesn't need any runqueue lock.

So in theory we should be able to safely transform
flush_scheduled_work() calls in network driver close
methods into cancel_work_sync()?

Could someone prepare that patch?

Thanks.
