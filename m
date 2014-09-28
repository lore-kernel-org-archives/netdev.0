From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: remove memory copy for rx path
Date: Sun, 28 Sep 2014 03:30:47 +0000
Message-ID: <65add7b63c4e41e49ef019bd58bbf404@BY2PR03MB377.namprd03.prod.outlook.com>
References: <20140926.170720.2230061639326332503.davem@davemloft.net>
	<057807be43ca4c79ad51ab07c668519d@BLUPR03MB373.namprd03.prod.outlook.com>
	<20140927113937.GA25265@electric-eye.fr.zoreil.com>
 <20140927.185600.1057301078747765304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.100.128] ([207.46.100.128]:7680 "EHLO
	na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753493AbaI1Dck convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 23:32:40 -0400
In-Reply-To: <20140927.185600.1057301078747765304.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net> Sent: Sunday, September 28, 2014 6:56 AM
>To: romieu@fr.zoreil.com
>Cc: Duan Fugang-B38611; Li Frank-B20596; netdev@vger.kernel.org;
>shawn.guo@linaro.org; bhutchings@solarflare.com
>Subject: Re: [PATCH] net: fec: remove memory copy for rx path
>
>From: Francois Romieu <romieu@fr.zoreil.com>
>Date: Sat, 27 Sep 2014 13:39:37 +0200
>
>> fugang.duan@freescale.com <fugang.duan@freescale.com> :
>>> From: David Miller <davem@davemloft.net> Sent: Saturday, September
>>> 27, 2014 5:07 AM
>> [...]
>>> >We call this rx_copybreak, and there are many drivers you can look
>>> >at to see how this works.
>>> >
>>> >Thanks.
>>>
>>> Great suggestion. I will change it for next version.
>>
>> Be aware that copybreak module option should be considered legacy.
>>
>> There is an ethtool api for it.
>
>Right.

Got it, thanks David and romieu. 

Regards,
Andy
