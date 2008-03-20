From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: use time_before() in br_fdb_cleanup()
Date: Thu, 20 Mar 2008 15:55:07 -0700 (PDT)
Message-ID: <20080320.155507.23109025.davem@davemloft.net>
References: <20080318093229.306b27d6@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752529AbYCTWyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 18:54:54 -0400
In-Reply-To: <20080318093229.306b27d6@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 18 Mar 2008 09:32:29 -0700

> In br_fdb_cleanup() next_timer and this_timer are in jiffies, so they
> should be compared using the time_after() macro.
> 
> Signed-off-by: Fabio Checconi <fabio@gandalf.sssup.it>
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

Applied, thanks.
