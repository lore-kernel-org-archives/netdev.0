From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] HFSC patches
Date: Tue, 09 Aug 2016 16:18:30 -0700 (PDT)
Message-ID: <20160809.161830.690816720663424002.davem@davemloft.net>
References: <1470177895-2453-1-git-send-email-soltys@ziu.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: soltys@ziu.info
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932521AbcHIXSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 19:18:31 -0400
In-Reply-To: <1470177895-2453-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Soltys <soltys@ziu.info>
Date: Wed,  3 Aug 2016 00:44:53 +0200

> Changes since v1:
> 
> - in the first patch's commit message, reference old patch using kernel.org's
>   historical tree (instead of using gmane)
> - in the second patch we just remove variable
> 
> Notes regarding patch #1/2:
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

I applied this series to net-next, thanks Michal.
