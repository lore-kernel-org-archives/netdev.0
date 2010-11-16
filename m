From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] irda: irttp: allow zero byte packets
Date: Tue, 16 Nov 2010 09:51:01 -0800 (PST)
Message-ID: <20101116.095101.115945762.davem@davemloft.net>
References: <1289344787-12160-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	samuel@sortiz.org
To: w.sang@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753696Ab0KPRuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 12:50:37 -0500
In-Reply-To: <1289344787-12160-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <w.sang@pengutronix.de>
Date: Wed, 10 Nov 2010 00:19:47 +0100

> Sending zero byte packets is not neccessarily an error (AF_INET accepts it,
> too), so just apply a shortcut. This was discovered because of a non-working
> software with WINE. See
> 
>   http://bugs.winehq.org/show_bug.cgi?id=19397#c86
>   http://thread.gmane.org/gmane.linux.irda.general/1643
> 
> for very detailed debugging information and a testcase. Kudos to Wolfgang for
> those!
> 
> Reported-by: Wolfgang Schwotzer <wolfgang.schwotzer@gmx.net>
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
> Tested-by: Mike Evans <mike.evans@cardolan.com>

This looks good to me, applied, thanks!
