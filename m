From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1] enet: fec: fix fail resume from suspend state
Date: Wed, 27 Mar 2013 07:17:09 +0800
Message-ID: <CAHrpEqQ2oThx1mTmyD=pBXJofsOx2wWdAA_DfygZu+FKT+ibSg@mail.gmail.com>
References: <1364264097-26157-1-git-send-email-Frank.Li@freescale.com>
	<20130326.121940.937673963522554506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank.Li@freescale.com, shawn.guo@linaro.org,
	u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:53112 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755652Ab3CZXRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 19:17:11 -0400
Received: by mail-we0-f180.google.com with SMTP id r5so4183676wey.25
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 16:17:09 -0700 (PDT)
In-Reply-To: <20130326.121940.937673963522554506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/3/27 David Miller <davem@davemloft.net>:
> From: Frank Li <Frank.Li@freescale.com>
> Date: Tue, 26 Mar 2013 10:14:57 +0800
>
>> Without this patch
>> 1. boot with nfs (no_console_suspend)
>> 2. echo mem >/sys/power/state
>> 3. wakeup by wakesource
>> 4. print "eth0: tx queue full"
>>
>> This fix above problem by reinit bd queue at restart function
>>
>> Signed-off-by: Frank Li <Frank.Li@freescale.com>
>
> Patch applies neither to 'net' nor 'net-next'.

I base on 3.9 -rc3, I will rebase it to net.

>
> Please respin this cleanly against current sources.
