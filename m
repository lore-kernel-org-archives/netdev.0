From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AX25: nuke user trigable printks
Date: Mon, 07 Jan 2008 21:55:50 -0800 (PST)
Message-ID: <20080107.215550.08459948.davem@davemloft.net>
References: <1199728513-25258-1-git-send-email-max@stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: max@stro.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45619
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754243AbYAHFzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:55:51 -0500
In-Reply-To: <1199728513-25258-1-git-send-email-max@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: maximilian attems <max@stro.at>
Date: Mon,  7 Jan 2008 18:55:13 +0100

> sfuzz trigerrs any of those printk easily.
> things that should have gone in early 2.5.x aka years ago
> should not be thrown so easily to the user.
> 
> Signed-off-by: maximilian attems <max@stro.at>

Can you replace the printk()'s with comments at least?

Otherwise nobody is going to remember what we were trying
to accomplish here and it will guarentee that, in fact,
support for these old things will never get removed.

At least if comments are there, someone might think to add
these things to the feature removal schedule and follow
through with it.

Thanks.
