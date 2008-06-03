From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix NULL pointer dereference and lockup.
Date: Tue, 03 Jun 2008 14:54:17 -0700 (PDT)
Message-ID: <20080603.145417.261803290.davem@davemloft.net>
References: <001a01c87692$cfca8d00$453c822c@dg8ngn>
	<20080224195101.GA2961@ami.dom.local>
	<20080526082345.GA27219@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, jann@gmx.de,
	thomas@osterried.de
To: ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52915
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752795AbYFCVyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 17:54:18 -0400
In-Reply-To: <20080526082345.GA27219@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 26 May 2008 09:23:45 +0100

> From: Jarek Poplawski <jarkao2@gmail.com>
> 
> There is only one function in AX25 calling skb_append(), and it really
> looks suspicious: appends skb after previously enqueued one, but in
> the meantime this previous skb could be removed from the queue.
> 
> This patch Fixes it the simple way, so this is not fully compatible with
> the current method, but testing hasn't shown any problems.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> ---
> I'm told Jarek is currently not reachable, so I'm submitting this for 2.6.26
> and -stable.

Applied, and queued up for -stable, thanks everyone.
