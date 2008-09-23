From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/8] drivers/atm: Use DIV_ROUND_UP
Date: Mon, 22 Sep 2008 19:23:24 -0700 (PDT)
Message-ID: <20080922.192324.149110500.davem@davemloft.net>
References: <200809222150.m8MLod61031866@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, julia@diku.dk, chas@cmf.nrl.navy.mil
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60638
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753988AbYIWCXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:23:36 -0400
In-Reply-To: <200809222150.m8MLod61031866@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:50:39 -0700

> The kernel.h macro DIV_ROUND_UP performs the computation (((n) + (d) - 1) /
> (d)) but is perhaps more readable.
> 
> In the case of the file drivers/atm/eni.c, I am a little bit suspicious of
> the -1 at the end of the affected expression.  Please check that that is
> what is wanted.
> 
> An extract of the semantic patch that makes this change is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
...
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Looks fine to me, applied to net-next-2.6
