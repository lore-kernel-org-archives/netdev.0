From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH v2] net: davinci_cpdma: remove excessive dump of register
 values to kernel log
Date: Wed, 27 Jul 2016 01:06:55 +0300
Message-ID: <e2e470ef-b4db-e13e-c9d6-4083a3ad9f2d@linaro.org>
References: <1469440485-19889-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20160725.175705.820422537273157170.davem@davemloft.net>
 <fd720b67-ca2b-fe28-c151-0a749fbba821@ti.com>
 <4c8afcb9-f7a9-4db3-e923-48dca5cacc3c@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mugunthanvnm@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, kernel@pengutronix.de
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	David Miller <davem@davemloft.net>,
	u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:33876 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161275AbcGZWG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 18:06:59 -0400
Received: by mail-lf0-f51.google.com with SMTP id l69so14653048lfg.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 15:06:58 -0700 (PDT)
In-Reply-To: <4c8afcb9-f7a9-4db3-e923-48dca5cacc3c@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 26.07.16 17:26, Grygorii Strashko wrote:
> + CC: Ivan
>
> On 07/26/2016 05:09 PM, Grygorii Strashko wrote:
>> On 07/26/2016 03:57 AM, David Miller wrote:
>>> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>>> Date: Mon, 25 Jul 2016 11:54:45 +0200
>>>
>>>> Such a big dump of register values is hardly useful on a productio=
n
>>>> system.
>>>>
>>>> Another downside of the now removed functions is that calling
>>>> emac_dump_regs resulted in at least 87 calls to dev_info while hol=
ding a
>>>> spinlock and having irqs off which is a big source of latency.
>>>>
>>>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>>>
>>> Applied.
>>>
>>
>> :( To be honest I was really enjoyed using cpdma_ctlr_dump()
>> for debug purposed during the past few weeks in cpsw where I've adde=
d
>> calls to this func manually. And I even thinking about adding debug_=
fs
>> entry for the same :(
>>
>> Pretty fast merge :(
At least, partly, for channel stats, for cpsw, I can use ethtool.
But ctrl_dump()... the function would be better to leave, redundant cal=
ls can be
removed from davinci_emac.

>>
>>
>
>

--=20
Regards,
Ivan Khoronzhuk
