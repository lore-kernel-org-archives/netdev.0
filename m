From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
Date: Sun, 17 Feb 2008 22:31:40 -0800 (PST)
Message-ID: <20080217.223140.193122711.davem@davemloft.net>
References: <20080206074529.GC4496@ff.dom.local>
	<20080213115607.GB2867@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jann@gmx.de, f6bvp@free.fr, ralf@linux-mips.org,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50517
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752538AbYBRGbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 01:31:04 -0500
In-Reply-To: <20080213115607.GB2867@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 13 Feb 2008 11:56:07 +0000

> [AX25] ax25_out: check skb for NULL in ax25_kick()
> 
> According to some OOPS reports ax25_kick tries to clone NULL skbs
> sometimes. It looks like a race with ax25_clear_queues(). Probably
> there is no need to add more than a simple check for this yet.
> Another report suggested there are probably also cases where ax25
> ->paclen == 0 can happen in ax25_output(); this wasn't confirmed
> during testing but let's leave this debugging check for some time.
> 
> Reported-and-tested-by: Jann Traschewski <jann@gmx.de>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.
