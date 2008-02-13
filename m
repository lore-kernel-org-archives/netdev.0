From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IRDA] irda_init() nuke useless debug printk
Date: Tue, 12 Feb 2008 18:17:42 -0800 (PST)
Message-ID: <20080212.181742.150703641.davem@davemloft.net>
References: <1202812247-6878-1-git-send-email-max@stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: max@stro.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754246AbYBMCRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 21:17:10 -0500
In-Reply-To: <1202812247-6878-1-git-send-email-max@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: maximilian attems <max@stro.at>
Date: Tue, 12 Feb 2008 11:30:47 +0100

> irda_init()
> dmesg line is not really informative, thus remove it.
> There are better ways to know that a module is loaded.
> 
> Seen on a debian config with IRDA_DEBUG enabled.
> 
> Signed-off-by: maximilian attems <max@stro.at>

Well if you look at how IRDA_DEBUG is predominantly used,
it's a function tracer, and that's exactly how it's being
used here.

Either we decide that this is OK and leave it there, or
we start moving the whole IRDA tree over to not do this.
Not something in between.
