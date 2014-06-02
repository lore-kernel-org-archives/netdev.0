From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] ethernet: marvell: After-TSO fixes
Date: Mon, 02 Jun 2014 16:16:40 -0700 (PDT)
Message-ID: <20140602.161640.476343365462203974.davem@davemloft.net>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, alior@marvell.com,
	tawfik@marvell.com, fugang.duan@freescale.com, w@1wt.eu
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbaFBXQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:16:41 -0400
In-Reply-To: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Fri, 30 May 2014 13:40:03 -0300

> This patchset consists of different fixes and improvements in the mvneta
> and mv643xx_eth drivers. The most important change is the one that allows
> to support small MSS values (see patches 2 and 6).
> 
> This is done following the Solarflare driver (see commit 7e6d06f0de3f7).
> 
> While doing this some other fixes were spotted and so they are included.
> 
> Finally, notice that the TSO support introduced a wrong DMA unmapping
> of the TSO header buffers, so patches 4 and 8 provide a couple patches to
> fix that in the drivers.

Series applied, but please address the feedback from Eric Dumazet.

Thanks!
