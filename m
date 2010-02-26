From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc35815: Fix double locking on NAPI
Date: Fri, 26 Feb 2010 01:51:44 -0800 (PST)
Message-ID: <20100226.015144.61780811.davem@davemloft.net>
References: <1267027234-7853-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935745Ab0BZJv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:51:26 -0500
In-Reply-To: <1267027234-7853-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Thu, 25 Feb 2010 01:00:34 +0900

> Isolate spinlock for tx and rx to resolve double-locking.
> 
> This is potential bug while this controller does not exist on any
> SMP platforms, but lockdep or rt-preempt reveals this bug.
> 
> Reported-by: Ralf Roesch <ralf.roesch@rw-gmbh.de>
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied.
