From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH 2/4] net: phy: at803x: Allow specifying the RGMII RX clock
 delay via phy mode
Date: Sun, 27 Dec 2015 21:22:48 +0100
Message-ID: <56804898.1030902@free.fr>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
 <1451089622-14957-3-git-send-email-martin.blumenstingl@googlemail.com>
 <567F5AD5.40004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mans Rullgard <mans@mansr.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:2617 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914AbbL0UWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2015 15:22:54 -0500
In-Reply-To: <567F5AD5.40004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/12/2015 04:28, Florian Fainelli wrote:

> Le 25/12/2015 16:27, Martin Blumenstingl wrote:
>
>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
>> index f566b6e..0b262a2 100644
>> --- a/drivers/net/phy/at803x.c
>> +++ b/drivers/net/phy/at803x.c
>> @@ -36,8 +36,10 @@
>>  #define AT803X_INSR				0x0013
>>  #define AT803X_DEBUG_ADDR			0x1D
>>  #define AT803X_DEBUG_DATA			0x1E
>> -#define AT803X_DEBUG_SYSTEM_MODE_CTRL		0x05
>> -#define AT803X_DEBUG_RGMII_TX_CLK_DLY		BIT(8)
>> +#define AT803X_DEBUG_REG_0			0x00
> 
> Seems like the previous register name might have been clearer that the
> new name you suggest here, did that come from a different GPL tarball or
> documentation?

http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf

According to the 8035 data sheet, the debug register at offset 0
is just "Debug register 0". In fact, the only non-reserved bit is
"rgmii rx clock delay enable/disable"

So the SYSTEM_MODE_CTRL name is misleading. Unless the register
has different semantics on the other PHYs?

Regards.
