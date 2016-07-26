From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2] net: davinci_cpdma: remove excessive dump of register
 values to kernel log
Date: Tue, 26 Jul 2016 17:26:39 +0300
Message-ID: <4c8afcb9-f7a9-4db3-e923-48dca5cacc3c@ti.com>
References: <1469440485-19889-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20160725.175705.820422537273157170.davem@davemloft.net>
 <fd720b67-ca2b-fe28-c151-0a749fbba821@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <mugunthanvnm@ti.com>, <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>, <kernel@pengutronix.de>
To: David Miller <davem@davemloft.net>,
	<u.kleine-koenig@pengutronix.de>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:41902 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552AbcGZO0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 10:26:52 -0400
In-Reply-To: <fd720b67-ca2b-fe28-c151-0a749fbba821@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ CC: Ivan

On 07/26/2016 05:09 PM, Grygorii Strashko wrote:
> On 07/26/2016 03:57 AM, David Miller wrote:
>> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>> Date: Mon, 25 Jul 2016 11:54:45 +0200
>>
>>> Such a big dump of register values is hardly useful on a production
>>> system.
>>>
>>> Another downside of the now removed functions is that calling
>>> emac_dump_regs resulted in at least 87 calls to dev_info while hold=
ing a
>>> spinlock and having irqs off which is a big source of latency.
>>>
>>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>>
>> Applied.
>>
>
> :( To be honest I was really enjoyed using cpdma_ctlr_dump()
> for debug purposed during the past few weeks in cpsw where I've added
> calls to this func manually. And I even thinking about adding debug_f=
s
> entry for the same :(
>
> Pretty fast merge :(
>
>


--=20
regards,
-grygorii
