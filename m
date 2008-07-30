From: David Miller <davem@davemloft.net>
Subject: Re: [patch 06/11] atm: fix direct casts of pointers to u32 in the
 InterPhase driver
Date: Wed, 30 Jul 2008 16:33:16 -0700 (PDT)
Message-ID: <20080730.163316.29825343.davem@davemloft.net>
References: <200807301937.m6UJbc12012442@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com, chas@cmf.nrl.navy.mil
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59908
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757415AbYG3XdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:33:16 -0400
In-Reply-To: <200807301937.m6UJbc12012442@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:37:38 -0700

> From: David Howells <dhowells@redhat.com>
> 
> Fix direct casts of pointers to u32 in the InterPhase ATM driver.  These are
> all arguments being passed to printk() calls.  So drop the cast and change the
> %x to a %p.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
