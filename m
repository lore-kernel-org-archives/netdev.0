From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: Fix FIFO flush issue
Date: Wed, 22 Feb 2012 15:26:55 -0500 (EST)
Message-ID: <20120222.152655.1621146586285854624.davem@davemloft.net>
References: <1329937090-20779-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stevenchen@jmicron.com,
	devinchiu@jmicron.com, angelli@jmicron.com, federico@quagliata.org,
	stable@kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214Ab2BVU2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 15:28:07 -0500
In-Reply-To: <1329937090-20779-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Thu, 23 Feb 2012 02:58:10 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> Set the RX FIFO flush watermark lower.
> According to Federico and JMicron's reply,
> setting it to 16QW would be stable on most platforms.
> Otherwise, user might experience packet drop issue.
> 
> CC: stable@kernel.org
> Reported-by: Federico Quagliata <federico@quagliata.org>
> Fixed-by: Federico Quagliata <federico@quagliata.org>
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
