From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] smsc9420: fix interrupt signalling test failures
Date: Thu, 29 Jan 2009 17:29:23 -0800 (PST)
Message-ID: <20090129.172923.24519684.davem@davemloft.net>
References: <1233247163-4317-1-git-send-email-steve.glendinning@smsc.com>
	<1233247163-4317-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55239
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752335AbZA3B3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 20:29:25 -0500
In-Reply-To: <1233247163-4317-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu, 29 Jan 2009 16:39:23 +0000

> smsc9420 performs an interrupt signalling test when the interface is
> brought up.  The current code mistakenly sets its test flag to false
> AFTER enabling the software interrupt source, making failure quite
> likely.
> 
> This patch changes the code to set the test flag BEFORE enabling
> interrupts. I've also removed an smp_wmb because the following spinlock
> provides an implicit memory barrier.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied, thanks Steve.
