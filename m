From: Arun Chandran <achandran@mvista.com>
Subject: Re: [PATCH v3] net: macb: Add big endian CPU support
Date: Sat, 28 Feb 2015 16:13:15 +0530
Message-ID: <CAFdej01eLmP8WaE0Eex8sXP0UYJdpqreQr1jQ3psiGcXELXr0A@mail.gmail.com>
References: <54EEF9C6.8070701@monstr.eu>
	<1424948474-11872-1-git-send-email-achandran@mvista.com>
	<20150227.172430.705343480463996651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Michal Simek <monstr@monstr.eu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:45069 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbbB1KnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 05:43:16 -0500
Received: by igjz20 with SMTP id z20so6585365igj.4
        for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 02:43:15 -0800 (PST)
In-Reply-To: <20150227.172430.705343480463996651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

>> This patch converts all __raw_readl and __raw_writel function calls
>> to their corresponding readl_relaxed and writel_relaxed variants.
>>
>> It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
>> when the CPU is configured in big endian mode.
>>
>> Signed-off-by: Arun Chandran <achandran@mvista.com>
>
> This does not apply cleanly to net-next, please respin.


The net-next tree already contains the initial version
of this change (commit: a50dad355a5314da64586da36804b86fbebb7c2a).

This applies cleanly if you revert that.

#~/work/open_source/net-next/net-next$ git log -2
commit 3cbef72505634b346dadb5f4ffd0fdb68c07710c
Author: Arun Chandran <achandran@mvista.com>
Date:   Wed Feb 18 16:35:44 2015 +0530

    net: macb: Add big endian CPU support

    This patch converts all __raw_readl and __raw_writel function calls
    to their corresponding readl_relaxed and writel_relaxed variants.

    It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
    when the CPU is configured in big endian mode.

    Signed-off-by: Arun Chandran <achandran@mvista.com>

commit 693aba8f896f286d9ddd4445ced374d2c96b41a2
Author: Arun Chandran <achandran@mvista.com>
Date:   Sat Feb 28 16:03:18 2015 +0530

    Revert "net: macb: Add big endian CPU support"

    This reverts commit a50dad355a5314da64586da36804b86fbebb7c2a.

--Arun
