From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 2/7] ATM cell alignment.
Date: Fri, 11 Apr 2008 06:53:46 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804110650390.16547@ask.diku.dk>
References: <200804101435.m3AEZ0bf008603@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:44803 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757936AbYDKExu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 00:53:50 -0400
In-Reply-To: <200804101435.m3AEZ0bf008603@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Apr 2008, Chas Williams (CONTRACTOR) wrote:

> In message <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk>,Jesper Dangaard Brou
> er writes:
>> +#define ATM_CELL_SIZE               53  /* ATM cell size incl. header */
>> +#define ATM_CELL_PAYLOAD            48  /* ATM payload size */
>
> these constants are already in linux/atm.h

Yes, I remember.  My original patch also contained some #ifndef's to 
handle that case.  I cannot remember, but there was some reason why I 
needed those, something about the ATM part of TC not always being 
included.

+#ifndef ATM_CELL_SIZE
+#define ATM_CELL_SIZE               53  /* ATM cell size incl. header */
+#endif
+#ifndef ATM_CELL_PAYLOAD
+#define ATM_CELL_PAYLOAD            48  /* ATM payload size */
+#endif

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
