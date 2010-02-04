From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] hardware/mISDN/mISDNinfineon.c: bail out of loop
 on error
Date: Wed, 03 Feb 2010 20:17:25 -0800 (PST)
Message-ID: <20100203.201725.75380164.davem@davemloft.net>
References: <201002022243.o12MhjvM019218@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	darrenrjenkins@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757009Ab0BDERM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:17:12 -0500
In-Reply-To: <201002022243.o12MhjvM019218@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 02 Feb 2010 14:43:45 -0800

> From: Darren Jenkins <darrenrjenkins@gmail.com>
> 
> If setup_instance() fails we kfree() the card, and then use it in the next
> loop iteration.  So lets bail out of the loop instead.
> 
> Coverity CID: 13357
> 
> Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
