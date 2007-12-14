From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Fri, 14 Dec 2007 11:30:55 -0800 (PST)
Message-ID: <20071214.113055.134616186.davem@davemloft.net>
References: <200712140002.lBE02aGO025491@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53132
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764105AbXLNTbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:31:02 -0500
In-Reply-To: <200712140002.lBE02aGO025491@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 13 Dec 2007 16:02:36 -0800

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> ASSERT_RTNL() uses mutex_trylock(), but it's better to use mutex_is_locked().
> 
> Make that change, and remove rtnl_trylock() altogether.
> 
> (not tested yet!)
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

NACK, as explained please remove this until the replacement
doesn't remove valid checks which are done currently.
