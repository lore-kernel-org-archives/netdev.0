From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/4] isdn: mISDN, don't compile unused stuff
Date: Wed, 03 Feb 2010 20:17:33 -0800 (PST)
Message-ID: <20100203.201733.105426974.davem@davemloft.net>
References: <201002022243.o12MhkQJ019221@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, jirislaby@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35945
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756886Ab0BDERU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:17:20 -0500
In-Reply-To: <201002022243.o12MhkQJ019221@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 02 Feb 2010 14:43:46 -0800

> From: Jiri Slaby <jirislaby@gmail.com>
> 
> Remove these compiler warnings:
> 
> drivers/isdn/hardware/mISDN/w6692.c:534: warning: `setvolume' defined but not used
> drivers/isdn/hardware/mISDN/w6692.c:561: warning: `enable_pots' defined but not used
> 
> by moving the functions inside #if 0 ...  #endif.  And an alternative is
> to remove them completely if nobody has plans to use them.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
