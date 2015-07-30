From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] gianfar: Fix warnings when built on 64-bit
Date: Wed, 29 Jul 2015 22:57:40 -0700 (PDT)
Message-ID: <20150729.225740.248853332948489247.davem@davemloft.net>
References: <1438175586-11614-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, scottwood@freescale.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbG3F5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 01:57:41 -0400
In-Reply-To: <1438175586-11614-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 29 Jul 2015 16:13:06 +0300

> From: Scott Wood <scottwood@freescale.com>
> 
> As part of defconfig consolidation using fragments, we'd like to be
> able to have the same drivers enabled on 32-bit and 64-bit.  Gianfar
> happens to only exist on 32-bit systems, and when building the
> resulting 64-bit kernel warnings were produced.
> 
> A couple of the warnings are trivial, but the rfbptr code has deeper
> issues.  It uses the virtual address as the DMA address, which again,
> happens to work in the environments where this driver is currently
> used, but is not the right thing to do.
> 
> Fixes: 45b679c9a3cc ("gianfar: Implement PAUSE frame generation
> support")
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks.

 
