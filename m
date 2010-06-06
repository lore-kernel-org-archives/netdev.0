From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: fix random mdio_write failures
Date: Sun, 06 Jun 2010 15:39:11 -0700 (PDT)
Message-ID: <20100606.153911.45884246.davem@davemloft.net>
References: <4C0A1736.9030209@iki.fi>
	<1275733273-28321-1-git-send-email-timo.teras@iki.fi>
	<20100605124103.GA3213@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org,
	edward_hsu@realtek.com.tw, hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37069
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751538Ab0FFWjD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jun 2010 18:39:03 -0400
In-Reply-To: <20100605124103.GA3213@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 5 Jun 2010 14:41:03 +0200

> Timo Ter=E4s <timo.teras@iki.fi> :
> [...]
>> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
>> index 217e709..03a8318 100644
>> --- a/drivers/net/r8169.c
>> +++ b/drivers/net/r8169.c
>> @@ -559,6 +559,11 @@ static void mdio_write(void __iomem *ioaddr, in=
t reg_addr, int value)
>>  			break;
>>  		udelay(25);
>>  	}
>> +	/*
>> +	 * Some configurations require a small delay even after the write
>> +	 * completed indication or the next write might fail.
>> +	 */
>> +	udelay(25);
>=20
> Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied, thanks everyone.
