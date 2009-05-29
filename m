From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4 v2] netdev: bfin_mac: fix malformed UDP packet
 transmission when polling with KGDB
Date: Fri, 29 May 2009 15:49:48 -0700 (PDT)
Message-ID: <20090529.154948.232160792.davem@davemloft.net>
References: <1243404615-25879-3-git-send-email-vapier@gentoo.org>
	<1243604443-27204-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com, cooloney@kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751472AbZE2Wts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 18:49:48 -0400
In-Reply-To: <1243604443-27204-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 29 May 2009 09:40:43 -0400

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> Writes to the DMA descriptors may sit in the internal Blackfin data buffers
> and not actually be available when the DMA engine goes to fetch them.  This
> does not typically happen, but when dealing with short/fast packets such as
> UDP and polling KGDB, this occurs much more frequently.  Same goes for
> heavy loads as seen by netperf tests or large scp transfers.  So force the
> buffers to drain with SSYNC otherwise we get random malformed packets.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>

Applied to net-next-2.6
