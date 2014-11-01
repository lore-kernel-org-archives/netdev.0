From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: systemport: TX dma fixes
Date: Sat, 01 Nov 2014 15:14:43 -0400 (EDT)
Message-ID: <20141101.151443.2080560572800614672.davem@davemloft.net>
References: <1414795895-31612-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950AbaKATOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 15:14:46 -0400
In-Reply-To: <1414795895-31612-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 31 Oct 2014 15:51:33 -0700

> This patch series contains two fixes for our transmit path, first one
> is a pretty nasty one since we were not allocating a large enough
> dma coherent pool for our transmit descriptors, which would work most of the
> time, since allocations are contiguous and we could have.
> 
> Second patch fixes a less frequent, though highly likley crash when using
> CMA allocations.

Series applied, thanks.

> I just missed your pull request to Linus, though I assume there will be
> another one?

Yes, there should be another one, or two, or three, or...
