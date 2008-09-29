From: Wang Jian <lark@linux.net.cn>
Subject: Re: drivers/net/phy/marvell.c: 88e1111 can't get out sleep mode
Date: Tue, 30 Sep 2008 00:28:26 +0800
Message-ID: <48E1022A.4000308@linux.net.cn>
References: <20080929133305.GA10554@debian> <1222699540.4579.7.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jeff@garzik.org>,
	Alexandr Smirnov <asmirnov@ru.mvista.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [210.82.31.146] ([210.82.31.146]:54278 "EHLO mx.linux.net.cn"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751482AbYI2Q23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 12:28:29 -0400
In-Reply-To: <1222699540.4579.7.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to datasheet, fiber/copper auto detect & auto switch depend on
energy detect.

Or I misunderstand DIS_FC & DIS_SLEEP? When DIS_SLEEP is set, fiber/copper
auto detect & auto switch still work?

Ben Hutchings wrote:
> On Mon, 2008-09-29 at 21:33 +0800, Wang Jian wrote:
>> Hi,
>>
>> During my testing, I found that 88e1111 can't get out of sleep mode
>> (Energy detect+) in certain condition.
> [...]
> 
> We had the same problem with development boards using that PHY and we
> stopped using the energy detect mode.
> 
> Ben.
> 

