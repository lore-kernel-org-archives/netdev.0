From: Alexandre Torgue <alexandre.torgue@gmail.com>
Subject: Re: [PATCH 0/4] Add Ethernet support on STM32F429
Date: Fri, 12 Feb 2016 16:01:10 +0100
Message-ID: <CAJgp7zxMoHD+zqHgsOvB=+wx=TtqqL0HH_3o=J=712QsvJvZwQ@mail.gmail.com>
References: <1454511275-9791-1-git-send-email-alexandre.torgue@gmail.com>
	<20160209.045214.805916119264070573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34336 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbcBLPBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 10:01:11 -0500
In-Reply-To: <20160209.045214.805916119264070573.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I will fix it in next patch version.
I just find a corruption issue in stmmac driver, I will also fix it in
next version.

Best regards

Alex

2016-02-09 10:52 GMT+01:00 David Miller <davem@davemloft.net>:
> From: Alexandre TORGUE <alexandre.torgue@gmail.com>
> Date: Wed,  3 Feb 2016 15:54:31 +0100
>
>> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
>> This series:
>>       -enhance current stmmac driver to control it (code already available) and
>>        adds basic glue for STM32F429 chip.
>>       -Enable basic Net config in kernel.
>>
>> Note that DT patches are not present because STM32 pinctrl code is not
>> yet avalaible.
>
> Looks like this needs to be respun to deal with the warnings the kbuild
> robot reported.
>
> Thanks.
