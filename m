From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.27-rc1-git4 BUG: sched while atomic
Date: Mon, 04 Aug 2008 14:40:20 -0700 (PDT)
Message-ID: <20080804.144020.106451038.davem@davemloft.net>
References: <20080804094835.da083484.randy.dunlap@oracle.com>
	<20080804101712.659780ef@extreme>
	<1217859640.6746.2.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, randy.dunlap@oracle.com,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1770225AbYHDVkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 17:40:23 -0400
In-Reply-To: <1217859640.6746.2.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 04 Aug 2008 07:20:40 -0700

> This was introduced by:
> 
> tg3: adapt tg3 to use reworked PCI PM code
> 
> Adapt the tg3 driver to use the reworked PCI PM and make it use the
> exported PCI PM core functions instead of accessing the PCI PM registers
> directly by itself.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> In the original tg3 code, we used udelay() when switching to D0 state
> since we were inside tg3_full_lock().

Right, this change was obviously not tested properly.

I'm likely going to revert unless a really good fix shows up fast.
