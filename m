From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: cpsw fails to come up once in a while
Date: Thu, 15 Aug 2013 16:06:19 +0530
Message-ID: <520CAF23.80500@ti.com>
References: <20130814175439.GA13483@linutronix.de> <520CA67F.4000902@ti.com> <520CA9A1.4050205@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:40646 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752717Ab3HOKgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 06:36:32 -0400
In-Reply-To: <520CA9A1.4050205@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 August 2013 03:42 PM, Sebastian Andrzej Siewior wrote:
> On 08/15/2013 11:59 AM, Mugunthan V N wrote:
>> This is a unknown issue. Will arrange a setup to test this scenario and
>> fix the issue.
> Ah, cool. Once in this state I tried various things but nothing helped.
> I tried to reset the HW phy and see if this helped but it ended while I
> looking for schematics and I though maybe it is easier to ask first.
In AM335x EVM, you need to probe a wire if you need to reset phy manually.
>
> One think I noticed in __davinci_mdio_reset() is that
> data->access_time is set via usecs_to_jiffies() and then used by
> msleep(). Since msleep() expects ms and not jiffies, this is wrong.
>
Yeah, just reviewed that code and you are correct. No need to convert as
it is already in ms value.

Regards
Mugunthan V N
