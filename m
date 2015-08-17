From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: Fix bandwidth allocation for some MF
 modes
Date: Mon, 17 Aug 2015 10:28:10 -0700 (PDT)
Message-ID: <20150817.102810.1079283414308199235.davem@davemloft.net>
References: <1439789305-4643-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbbHQR2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 13:28:14 -0400
In-Reply-To: <1439789305-4643-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 17 Aug 2015 08:28:25 +0300

> Management firmware tells driver in case bandwidth configuration for
> a specific function exists, but [regretably] the same field has different
> meanings depending on the multi-function mode - it can either be
> a percentile value or an actual speed.
> 
> For newer multi-function modes current logic is incorrect -
> driver understands values as actual speeds instead of percentages,
> causing the resulting chip configuration to be incorrect.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> ---
> Hi Dave,
> 
> This is actually a bug fix - but as some of the targeted multi-function
> modes exists only in 'net-next' at this time, I'm designating this fix
> to 'net-next' as well.
> 
> Please consider applying this one.

Applied to net-next, thanks.
