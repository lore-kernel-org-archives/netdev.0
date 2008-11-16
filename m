From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] niu: bitwise or does not imply ordering
Date: Sun, 16 Nov 2008 12:37:32 -0800 (PST)
Message-ID: <20081116.123732.74733883.davem@davemloft.net>
References: <312268717986b8b45674.846930886.miltonm@bga.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, segher@kernel.crashing.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: miltonm@bga.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752084AbYKPUhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 15:37:33 -0500
In-Reply-To: <312268717986b8b45674.846930886.miltonm@bga.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Milton Miller <miltonm@bga.com>
Date: Sun, 16 Nov 2008 15:43:18 -0600

> commit e23a59e1ca6d177a57a7791b3629db93ff1d9813 (niu: Fix readq
> implementation when architecture does not provide one.) reordered the
> arguments to a bitwise or to change the emitted code.   However, C does
> not guarantee the evaluation order.

I'm not applying this patch, the problem is in your
imagination only.
