From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v2 1/2 net-next] net: fec: fix miss init spinlock
Date: Thu, 7 Feb 2013 09:37:43 +0800
Message-ID: <CAHrpEqTOsan3EyK-YZXiZ76HtpT9MVWm=QQk5V+mT0reNU9twQ@mail.gmail.com>
References: <1360045577-6266-1-git-send-email-Frank.Li@freescale.com>
	<20130206.150431.408313770070806281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank.Li@freescale.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, shawn.guo@linaro.org, B38611@freescale.com,
	s.hauer@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:63170 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715Ab3BGBho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 20:37:44 -0500
Received: by mail-wg0-f43.google.com with SMTP id e12so1575857wge.34
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 17:37:43 -0800 (PST)
In-Reply-To: <20130206.150431.408313770070806281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/7 David Miller <davem@davemloft.net>:
> From: Frank Li <Frank.Li@freescale.com>
> Date: Tue, 5 Feb 2013 14:26:16 +0800
>
>> Change from v1 to v2
>>  - avoid reinit hwreg_lock twice
>
> I already applied your v1 patch, so you have to revert that spin_lock_init()
> call in this change.
>
> Please do that and respin this patch series.

Okay
