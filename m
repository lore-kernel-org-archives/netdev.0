From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cleanup extra semicolons
Date: Fri, 20 Apr 2007 17:10:12 -0700 (PDT)
Message-ID: <20070420.171012.24611103.davem@davemloft.net>
References: <20070403120009.4f3b41b7@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57881
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752875AbXDUAKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 20:10:09 -0400
In-Reply-To: <20070403120009.4f3b41b7@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 3 Apr 2007 12:00:09 -0700

> Spring cleaning time...
> 
> There seems to be a lot of places in the network code that have
> extra bogus semicolons after conditionals.  Most commonly is a
> bogus semicolon after: switch() { }
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.22, thanks Stephen.

I'm the main guilty party for the switch() statement cases.
I saw someone use that convention long ago and I picked up on
it for some reason. :-)
