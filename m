From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4] mISDN: positive error return should be negative in
 mode_hfcmulti()
Date: Wed, 03 Feb 2010 20:17:46 -0800 (PST)
Message-ID: <20100203.201746.160475402.davem@davemloft.net>
References: <201002022243.o12MhlfZ019228@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, roel.kluin@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757133Ab0BDERc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:17:32 -0500
In-Reply-To: <201002022243.o12MhlfZ019228@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 02 Feb 2010 14:43:47 -0800

> From: Roel Kluin <roel.kluin@gmail.com>
> 
> The error return should be negative.  Its only caller that acts upon its
> return, handle_bmsg(), transmits the positive error but can also return
> negative errors.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
