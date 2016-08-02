From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] HFSC patches
Date: Mon, 01 Aug 2016 21:27:11 -0700 (PDT)
Message-ID: <20160801.212711.1833470473467715535.davem@davemloft.net>
References: <1470006239-20299-1-git-send-email-soltys@ziu.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: soltys@ziu.info
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbcHBE2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 00:28:13 -0400
In-Reply-To: <1470006239-20299-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Soltys <soltys@ziu.info>
Date: Mon,  1 Aug 2016 01:03:57 +0200

> - first patch:
> 
> This patch syncs virtual times with fair service curve and fixes a very old
> subtle bug.
> 
> The detailed explanation is in the commit message. Additionally
> I've made an illustration to help understand the issue better:
> 
> http://imgur.com/a/N8uMC
> 
> See the example at the bottom of the commit message - Am1_3 and Am2_3 is what
> should happen with such queue setup, Am1_3real and Am2_3real is what actually
> happens due to rtsc_min() calculating minimum from corrected and uncorrected
> curves.
> 
> - second patch:
> 
> This is trivial patch that comments out one unused variable, related to another
> commented out piece of code.

Don't just comment it out, if it's unused delete it entirely.
