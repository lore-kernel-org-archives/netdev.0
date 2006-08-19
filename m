From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: limit window scaling if window is clamped
Date: Fri, 18 Aug 2006 17:00:30 -0700 (PDT)
Message-ID: <20060818.170030.74563682.davem@davemloft.net>
References: <20060818102938.5abc1bcf@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52913
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751592AbWHSAA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 20:00:28 -0400
To: shemminger@osdl.org
In-Reply-To: <20060818102938.5abc1bcf@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 18 Aug 2006 10:29:38 -0700

> This small change allows for easy per-route workarounds for broken hosts or
> middleboxes that are not compliant with TCP standards for window scaling.
> Rather than having to turn off window scaling globally. This patch allows
> reducing or disabling window scaling if window clamp is present.
> 
> Example: Mark Lord reported a problem with 2.6.17 kernel being unable to
> access http://www.everymac.com
> 
> # ip route add 216.145.246.23/32 via 10.8.0.1 window 65535
> 
> I would argue this ought to go in stable kernel as well.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I want to think about this some more, it might have unintended
consequences.  I really am not all that thrilled about putting in
workaround for this problem especially if it hurts a legitimate use of
some kind.
