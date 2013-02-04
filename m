From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Mon, 04 Feb 2013 15:03:59 -0500 (EST)
Message-ID: <20130204.150359.599088894678143987.davem@davemloft.net>
References: <CAHrpEqSLx-J-1SYC6OapqidY+U3acnTmNyOj8UrNRZwYZRXCoQ@mail.gmail.com>
	<20130204.002410.508273179967651174.davem@davemloft.net>
	<CAHrpEqQwmAN8fBVQKOJzw5uD0WTfu9zR-gP1SPmq+JxocxjFSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, shawn.guo@linaro.org, B38611@freescale.com,
	s.hauer@pengutronix.de
To: lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687Ab3BDUEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 15:04:02 -0500
In-Reply-To: <CAHrpEqQwmAN8fBVQKOJzw5uD0WTfu9zR-gP1SPmq+JxocxjFSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <lznuaa@gmail.com>
Date: Mon, 4 Feb 2013 14:31:52 +0800

>>>> This breaks the build, tmreg_lock is only present in certain
>>>> configurations.
>>>
>>> No, FEC have changed to check dramatically instead of static config.
>>> You can look fec.h.  tmreg_lock is always defined.
>>
>> Not in the 'net' tree or you don't want this bug fixed there at all?
> 
> Sorry, I forget mask tree.
> This patch is for net-next.

Ok, applied to net-next.
