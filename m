From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib/vsprintf.c: Add %pMF to format FDDI bit reversed
 MAC addresses
Date: Thu, 07 Jan 2010 14:09:42 -0800 (PST)
Message-ID: <20100107.140942.135976087.davem@davemloft.net>
References: <BD79186B4FD85F4B8E60E381CAEE19090208954A@mi8nycmail19.Mi8.com>
	<1262888625.10429.23.camel@Joe-Laptop.home>
	<alpine.LFD.2.00.1001072037170.13474@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, hartleys@visionengravers.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751651Ab0AGWJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 17:09:36 -0500
In-Reply-To: <alpine.LFD.2.00.1001072037170.13474@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Thu, 7 Jan 2010 20:42:12 +0000 (GMT)

>  What's the gain?  I'd be rather conservative when taking everybody's 56 
> bytes for one or two drivers hardly anybody uses.  The format of MAC 
> addresses is unlikely to change, so I'd say the sources can live with 
> one or two places where the strings are formatted manually.  Even if the 
> drivers lose more than these 56 bytes.

We gain consistency.  You know, the part that's completely bolixed
right now?

I'm applying Joe's patch and followon patches to make the driver's
use the new printf format.
