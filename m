From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: factorize cache clearing for batched
 unregister operations
Date: Tue, 17 Nov 2009 00:35:19 -0800 (PST)
Message-ID: <20091117.003519.228058209.davem@davemloft.net>
References: <200911170149.50011.opurdila@ixiacom.com>
	<20091116160646.39c0a1ac@nehalam>
	<20091117002238.GH12422@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, opurdila@ixiacom.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: bcrl@lhnet.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49550
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753293AbZKQIfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 03:35:02 -0500
In-Reply-To: <20091117002238.GH12422@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@lhnet.ca>
Date: Mon, 16 Nov 2009 19:22:38 -0500

> It's not possible to create more than a few thousand IPv6 interfaces in 
> my tests with a 4GB vm.  The culprit seems to be the per-cpu arrays for 
> statistics using vmalloc() and wasting gobs of memory as a result (memory 
> usage seems to be 10x per interface vs what IPv4 is using), but I haven't 
> dug too deeply yet.

That definitely should be fixed.
