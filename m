From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] nfp: use correct index to mask link state irq
Date: Thu, 16 Jun 2016 22:03:19 -0700 (PDT)
Message-ID: <20160616.220319.1402917346658106257.davem@davemloft.net>
References: <1466084570-26549-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbcFQFDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 01:03:23 -0400
In-Reply-To: <1466084570-26549-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 16 Jun 2016 14:42:50 +0100

> We were using an incorrect define to get the irq vector number.
> NFP_NET_CFG_LSC is a control BAR offset, LSC interrupt vector
> index is called NFP_NET_IRQ_LSC_IDX.  For machines with less
> than 30 CPUs this meant that we were disabling/enabling IRQ 0.
> For bigger hosts we were just playing with the 31st RX/TX
> interrupt.
> 
> Fixes: 0ba40af963f0 ("nfp: move link state interrupt request/free calls")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied.
