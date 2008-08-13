From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Protect gen estimators under
 est_lock.
Date: Wed, 13 Aug 2008 15:20:42 -0700 (PDT)
Message-ID: <20080813.152042.220622907.davem@davemloft.net>
References: <20080811205357.GA15293@ami.dom.local>
	<20080812220218.GA12387@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751654AbYHMWUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 18:20:40 -0400
In-Reply-To: <20080812220218.GA12387@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 13 Aug 2008 00:02:18 +0200

> pkt_sched: Protect gen estimators under est_lock.
> 
> gen_kill_estimator() required rtnl_lock() protection, but since it is
> moved to an RCU callback __qdisc_destroy() let's use est_lock instead.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Looks good, applied, thanks Jarek.
