From: David Miller <davem@davemloft.net>
Subject: Re: [patch 6/8] drivers/net/wan: Use DIV_ROUND_UP
Date: Mon, 22 Sep 2008 19:24:23 -0700 (PDT)
Message-ID: <20080922.192423.184278021.davem@davemloft.net>
References: <200809222150.m8MLogbY031872@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, julia@diku.dk, chas@cmf.nrl.navy.mil
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60643
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754218AbYIWCYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:24:35 -0400
In-Reply-To: <200809222150.m8MLogbY031872@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:50:42 -0700

> The kernel.h macro DIV_ROUND_UP performs the computation (((n) + (d) - 1) /
> (d)) but is perhaps more readable.
> 
> An extract of the semantic patch that makes this change is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

[ Why is Chas being CC:'d on WAN driver layer patches?  He's the ATM
  maintainer :-) ]

Applied to net-next-2.6, thanks.
