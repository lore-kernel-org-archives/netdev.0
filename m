From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: Porting ethernet over spi driver
Date: Tue, 22 Apr 2014 11:42:43 +0200
Message-ID: <53563993.7010704@i2se.com>
References: <5350ED9E.6080103@lategoodbye.de> <CAOMZO5B-=6rqRgTVS+O+dDWq0SDE9_ytKdW38gN=gzzy-xwEtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stefan Wahren <info@lategoodbye.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.130]:53696 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206AbaDVJms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 05:42:48 -0400
In-Reply-To: <CAOMZO5B-=6rqRgTVS+O+dDWq0SDE9_ytKdW38gN=gzzy-xwEtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 22.04.2014 04:32, schrieb Fabio Estevam:
> On Fri, Apr 18, 2014 at 6:17 AM, Stefan Wahren <info@lategoodbye.de> wrote:
>> Hi,
>>
>> i'm trying to port a ethernet over spi driver to current mainline, which
>> originally based on kernel 2.6.
>>
>> Now i'm searching for some guidelines, checklists, common pitfalls or just
>> hints about that.
>>
>> Is there something about that, which is up to date?
>>
>> Is there a list or something of legacy function, which shouldn't be used
>> anymore?
>>
>> Are there any new must have features?
>>
>> Is there a good reference implementation for ethernet over spi?
> Not sure if it is a good reference, but the only one I am aware of is this one:
> drivers/net/ethernet/microchip/enc28j60.c

Yes, i already found this one and also:
drivers/net/ethernet/micrel/ks8851.c

Unfortunately neither of them have device tree support, so i took some
parts from here:
drivers/net/ethernet/freescale/fec_main.c

>
> Regards,
>
> Fabio Estevam
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

BR Stefan Wahren
