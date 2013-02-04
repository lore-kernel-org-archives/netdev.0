From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Mon, 4 Feb 2013 14:31:52 +0800
Message-ID: <CAHrpEqQwmAN8fBVQKOJzw5uD0WTfu9zR-gP1SPmq+JxocxjFSA@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<20130202.230851.809969826800130930.davem@davemloft.net>
	<CAHrpEqSLx-J-1SYC6OapqidY+U3acnTmNyOj8UrNRZwYZRXCoQ@mail.gmail.com>
	<20130204.002410.508273179967651174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank.Li@freescale.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, shawn.guo@linaro.org, B38611@freescale.com,
	s.hauer@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:60837 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab3BDGbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 01:31:53 -0500
Received: by mail-wg0-f53.google.com with SMTP id fn15so4538057wgb.32
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 22:31:52 -0800 (PST)
In-Reply-To: <20130204.002410.508273179967651174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> This breaks the build, tmreg_lock is only present in certain
>>> configurations.
>>
>> No, FEC have changed to check dramatically instead of static config.
>> You can look fec.h.  tmreg_lock is always defined.
>
> Not in the 'net' tree or you don't want this bug fixed there at all?

Sorry, I forget mask tree.
This patch is for net-next.

best regards
Frank Li
