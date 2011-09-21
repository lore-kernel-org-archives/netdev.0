From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smsc911x: Correctly configure 16-bit register
 access from DT
Date: Wed, 21 Sep 2011 15:18:59 -0400 (EDT)
Message-ID: <20110921.151859.1493899537665203423.davem@davemloft.net>
References: <1315910969-4018-1-git-send-email-dave.martin@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patches@linaro.org,
	steve.glendinning@smsc.com, shawn.guo@linaro.org,
	devicetree-discuss@lists.ozlabs.org
To: dave.martin@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476Ab1IUTVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 15:21:09 -0400
In-Reply-To: <1315910969-4018-1-git-send-email-dave.martin@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Martin <dave.martin@linaro.org>
Date: Tue, 13 Sep 2011 11:49:29 +0100

> The SMSC911X_USE_16BIT needs to be set when using 16-bit register
> access.  However, currently no flag is set if the device tree
> doesn't specify 32-bit access, resulting in a BUG() and a non-
> working driver when 16-bit register access is configured for
> smsc911x in the DT.
> 
> This patch should set the SMSC911X_USE_16BIT flag in a manner
> consistent with the documented DT bindings.
> 
> Signed-off-by: Dave Martin <dave.martin@linaro.org>

Applied to net-next, thanks.
