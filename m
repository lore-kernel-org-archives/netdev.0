From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 14:12:47 -0700 (PDT)
Message-ID: <20071005.141247.71101713.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005083924.4e7f5d59@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761633AbXJEVMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 17:12:51 -0400
In-Reply-To: <20071005083924.4e7f5d59@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:39:24 -0700

> Build failed on x86_64
> 
> ERROR: "__bad_udelay" [drivers/net/niu.ko] undefined!

Can you figure out which udelay() call is too big and
thus causing problems?
