From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 ver2 1/1] sch_htb: fix "too many events"
 situation
Date: Sun, 23 Mar 2008 22:01:55 -0700 (PDT)
Message-ID: <20080323.220155.35849585.davem@davemloft.net>
References: <E1JYLxN-00024M-HI@luxik.cdi.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: devik@cdi.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40003
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751788AbYCXFB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:01:56 -0400
In-Reply-To: <E1JYLxN-00024M-HI@luxik.cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Devera <devik@cdi.cz>
Date: Sun, 09 Mar 2008 14:52:53 +0100

> HTB is event driven algorithm and part of its work is to apply
> scheduled events at proper times. It tried to defend itself from
> livelock by processing only limited number of events per dequeue.
> Because of faster computers some users already hit this hardcoded
> limit.
> This patch limits processing up to 2 jiffies (why not 1 jiffie ?
> because it might stop prematurely when only fraction of jiffie
> remains).
> 
> Signed-off-by: Martin Devera <devik@cdi.cz>

Applied, and I'll queue this up for -stable too.

Thanks.
