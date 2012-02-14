From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: How to deal with a PHY configuration related to the board?
Date: Tue, 14 Feb 2012 15:01:09 +0100
Message-ID: <4F3A6925.2060601@atmel.com>
References: <20120214092606.GE4723@ldesroches-Latitude-E6320> <20120214094339.GA4338@sapphire.tkos.co.il> <20120214103318.GF4723@ldesroches-Latitude-E6320> <20120214112248.GA20876@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ludovic Desroches <ludovic.desroches@atmel.com>,
	Baruch Siach <baruch@tkos.co.il>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:20987 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755380Ab2BNOBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 09:01:30 -0500
In-Reply-To: <20120214112248.GA20876@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2012 12:22 PM, Jean-Christophe PLAGNIOL-VILLARD :
> On 11:33 Tue 14 Feb     , Ludovic Desroches wrote:
>> Hi Baruch,
>>
>> On Tue, Feb 14, 2012 at 11:43:39AM +0200, Baruch Siach wrote:
>>> Hi Ludovic,
>>>
>>> On Tue, Feb 14, 2012 at 10:26:06AM +0100, Ludovic Desroches wrote:
>>>> I am using a Micrel KSZ9021RN PHY and I would like to configure some 
>>>> registers
>>>> as 'RGMII Clock and Control Pad Skew' and 'RGMII RX Data Pad Skew'.
>>>> So the values of these registers are board dependant and I wondering what is
>>>> the proper way to set them.
>>>> It seems there is no platform data usable for this case. Having a quick look
>>>> to other PHYs, the situation seems the same.
>>>>
>>>> Can you give me some clues about how to do this? Did I miss anything which
>>>> allow to do this?
>>>
>>> See ksz9021rn_phy_fixup() in arch/arm/mach-imx/mach-imx6q.c.
>>>
>>
>> Thanks for your help.
>>
>> So the solution is to use phy_register_fixup function.
> dts

?

Can you please build sentences?

(even if I suspect to know what you are talking about ;-))

Bye,
-- 
Nicolas Ferre
