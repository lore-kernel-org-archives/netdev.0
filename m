From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/8] hysdn: remove cli()/sti() calls
Date: Wed, 14 May 2008 16:41:40 -0700 (PDT)
Message-ID: <20080514.164140.229890751.davem@davemloft.net>
References: <200805142319.m4ENJh0C026560@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mark.asselstine@windriver.com,
	kkeil@suse.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42317
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752110AbYENXlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:41:45 -0400
In-Reply-To: <200805142319.m4ENJh0C026560@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 14 May 2008 16:19:43 -0700

> From: Mark Asselstine <mark.asselstine@windriver.com>
> 
> The use of cli()/sti() within the do/while was a way to ensure interrupts were
> only disabled for short periods of time while the bulk of the time interrupts
> were free to occur.  The use of the spin lock has eliminated the need to play
> with interrupts in this way while still allowing for IO to be protected.
> 
> The remaining 3 sti() calls seem unneeded now that at no other point in the
> driver is there a call to cli().
> 
> Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
> Acked-by: Karsten Keil <kkeil@suse.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: David S. Miller <davem@davemloft.net>
