From: David Miller <davem@davemloft.net>
Subject: Re: [patch 14/15] rfcomm_worker(): fix wakeup race
Date: Thu, 26 Apr 2007 01:41:09 -0700 (PDT)
Message-ID: <20070426.014109.102121955.davem@davemloft.net>
References: <200704260727.l3Q7RacZ023984@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56530
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933675AbXDZIlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:41:01 -0400
In-Reply-To: <200704260727.l3Q7RacZ023984@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Thu, 26 Apr 2007 00:27:36 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Set TASK_INTERRUPTIBLE prior to testing the flag to avoid missed wakeups.
> 
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
