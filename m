From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ipv4: Remove redundant NULL check
Date: Tue, 05 Mar 2013 14:40:52 -0500 (EST)
Message-ID: <20130305.144052.577951922981506984.davem@davemloft.net>
References: <1362482829-10455-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755710Ab3CETky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 14:40:54 -0500
In-Reply-To: <1362482829-10455-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@linaro.org>
Date: Tue,  5 Mar 2013 16:57:09 +0530

> kfree on a null pointer is a NO-OP. Hence null check is not necessary.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Unnecessary writes to the socket struct should be avoided, as it
generates unnecessary write traffic to the L2 cache.

I'm not applying this.
