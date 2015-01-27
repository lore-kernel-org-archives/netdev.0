From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 0/4] net: phy: prevent double suspend
Date: Tue, 27 Jan 2015 11:16:34 -0800
Message-ID: <54C7E412.7010903@gmail.com>
References: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com> <54C7E140.4080908@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, s.hauer@pengutronix.de, b38611@freescale.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:42358 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667AbbA0TQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 14:16:54 -0500
Received: by mail-pd0-f181.google.com with SMTP id g10so20532153pdj.12
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 11:16:53 -0800 (PST)
In-Reply-To: <54C7E140.4080908@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/01/15 11:04, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/27/2015 09:05 AM, Florian Fainelli wrote:
> 
>> This patch series addresses a problem that Fugang and I observed on
>> different
>> platforms where a given PHY device might end-up being suspended twice.
> 
>> Once as part of the call from ndo_open() all the way down to
>> phy_detach() and
>> phy_suspend() and a second time when the generic platform device/driver
>> suspend/resume callbacks are called in drivers/net/phy/mdio_bus.c.
> 
>> Thanks to Fugang for giving this a quick try on i.MX6/FEC and reporting
>> positive test results!
> 
>    I can now confirm this patchset fixed our issue with an external
> abort during suspend on R-Car platform (with the 'sh_eth' driver)!

Great, thanks Sergei!

> 
>> Florian Fainelli (4):
>>    net: phy: utilize phy_suspend and phy_resume
>>    net: phy: document has_fixups field
>>    net: phy: keep track of the PHY suspend state
>>    net: phy: avoid suspending twice a PHY
> 
> WBR, Sergei
> 


-- 
Florian
