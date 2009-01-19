From: David Miller <davem@davemloft.net>
Subject: Re: 64k bind(0) bugfix.
Date: Mon, 19 Jan 2009 15:24:32 -0800 (PST)
Message-ID: <20090119.152432.32346720.davem@davemloft.net>
References: <20090119232151.GA13659@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752530AbZASXYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 18:24:30 -0500
In-Reply-To: <20090119232151.GA13659@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Tue, 20 Jan 2009 02:21:51 +0300

> I found the bug in bind conflict resolve path, when bundle was not
> unlocked after conflict was detected, attached patch should fix it.
> 
> If testing will reveal some new problems I will return with the fix
> then. Please apply or queue for the appropriate tree.
> 
> Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

Applied, thanks Evgeniy.

If I end up rebasing the net-next tree before publishing, I'll
integrate this fix into the original commit.
