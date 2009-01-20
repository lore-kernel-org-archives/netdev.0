From: David Miller <davem@davemloft.net>
Subject: Re: mv643xx broken on pegasos
Date: Mon, 19 Jan 2009 17:16:16 -0800 (PST)
Message-ID: <20090119.171616.232865263.davem@davemloft.net>
References: <20090115203214.GB18393@deprecation.cyrius.com>
	<20090118.215911.110220539.davem@davemloft.net>
	<20090119094523.GE17124@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tbm@cyrius.com, pacman@kosh.dhis.org, netdev@vger.kernel.org,
	matt@genesi-usa.com, paubert@iram.es
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39066
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752374AbZATBQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 20:16:15 -0500
In-Reply-To: <20090119094523.GE17124@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 19 Jan 2009 10:45:23 +0100

> Revert "mv643xx_eth: use longer DMA bursts".
> 
> This reverts commit cd4ccf76bfd2c36d351e68be7e6a597268f98a1a.
> 
> On the Pegasos board, we can't do DMA burst that are longer than
> one cache line.  For now, go back to using 32 byte DMA bursts for
> all mv643xx_eth platforms -- we can switch the ARM-based platforms
> back to doing long 128 byte bursts in the next development cycle.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> Reported-by: Alan Curry <pacman@kosh.dhis.org>
> Reported-by: Gabriel Paubert <paubert@iram.es>

Applied, thanks everyone.
