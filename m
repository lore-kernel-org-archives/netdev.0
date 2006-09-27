From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9][TG3]: Improve ASF heartbeat.
Date: Wed, 27 Sep 2006 16:01:23 -0700 (PDT)
Message-ID: <20060927.160123.78711404.davem@davemloft.net>
References: <1159389265.3411.19.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25254
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031203AbWI0XBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:01:25 -0400
To: mchan@broadcom.com
In-Reply-To: <1159389265.3411.19.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 27 Sep 2006 13:34:25 -0700

> [TG3]: Improve ASF heartbeat.
> 
> Change to a different ASF heartbeat message code to improve
> reliability.
> 
> There were some reports of unintended resets on real time kernels
> where the timer may be slow and cause the heartbeat to be late.
> Netpoll will also have the same problem because the timer irq will
> be unavailable.
> 
> Using the new heartbeat code, the ASF firmware will also check the
> ring condition before resetting the chip when the heartbeat is
> expiring.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.

But what exactly is meant by "checking the ring condition"?

Does it mean that if the ASF heartbeat times out, ASF will
check to see if the TX and/or RX ring are still making forward
progress and abort the reset if so?
