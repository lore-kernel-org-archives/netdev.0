From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2] net: davinci_cpdma: remove excessive dump of register
 values to kernel log
Date: Tue, 26 Jul 2016 17:09:19 +0300
Message-ID: <fd720b67-ca2b-fe28-c151-0a749fbba821@ti.com>
References: <1469440485-19889-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20160725.175705.820422537273157170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <mugunthanvnm@ti.com>, <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>, <kernel@pengutronix.de>
To: David Miller <davem@davemloft.net>,
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:41190 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbcGZOJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 10:09:33 -0400
In-Reply-To: <20160725.175705.820422537273157170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2016 03:57 AM, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Mon, 25 Jul 2016 11:54:45 +0200
>
>> Such a big dump of register values is hardly useful on a production
>> system.
>>
>> Another downside of the now removed functions is that calling
>> emac_dump_regs resulted in at least 87 calls to dev_info while holdi=
ng a
>> spinlock and having irqs off which is a big source of latency.
>>
>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>
> Applied.
>

:( To be honest I was really enjoyed using cpdma_ctlr_dump()
for debug purposed during the past few weeks in cpsw where I've added=20
calls to this func manually. And I even thinking about adding debug_fs=20
entry for the same :(

Pretty fast merge :(


--=20
regards,
-grygorii
