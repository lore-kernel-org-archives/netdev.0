From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 0/4] net: phy: prevent double suspend
Date: Tue, 27 Jan 2015 22:04:32 +0300
Message-ID: <54C7E140.4080908@cogentembedded.com>
References: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, s.hauer@pengutronix.de, b38611@freescale.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:63952 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbbA0TEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 14:04:37 -0500
Received: by mail-la0-f46.google.com with SMTP id s18so15063126lam.5
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 11:04:35 -0800 (PST)
In-Reply-To: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/27/2015 09:05 AM, Florian Fainelli wrote:

> This patch series addresses a problem that Fugang and I observed on different
> platforms where a given PHY device might end-up being suspended twice.

> Once as part of the call from ndo_open() all the way down to phy_detach() and
> phy_suspend() and a second time when the generic platform device/driver
> suspend/resume callbacks are called in drivers/net/phy/mdio_bus.c.

> Thanks to Fugang for giving this a quick try on i.MX6/FEC and reporting
> positive test results!

    I can now confirm this patchset fixed our issue with an external abort 
during suspend on R-Car platform (with the 'sh_eth' driver)!

> Florian Fainelli (4):
>    net: phy: utilize phy_suspend and phy_resume
>    net: phy: document has_fixups field
>    net: phy: keep track of the PHY suspend state
>    net: phy: avoid suspending twice a PHY

WBR, Sergei
