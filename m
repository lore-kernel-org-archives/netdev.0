From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: cpsw fails to come up once in a while
Date: Thu, 15 Aug 2013 12:12:49 +0200
Message-ID: <520CA9A1.4050205@linutronix.de>
References: <20130814175439.GA13483@linutronix.de> <520CA67F.4000902@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:33563 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434Ab3HOKMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 06:12:51 -0400
In-Reply-To: <520CA67F.4000902@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2013 11:59 AM, Mugunthan V N wrote:
> This is a unknown issue. Will arrange a setup to test this scenario and
> fix the issue.

Ah, cool. Once in this state I tried various things but nothing helped.
I tried to reset the HW phy and see if this helped but it ended while I
looking for schematics and I though maybe it is easier to ask first.

One think I noticed in __davinci_mdio_reset() is that
data->access_time is set via usecs_to_jiffies() and then used by
msleep(). Since msleep() expects ms and not jiffies, this is wrong.

> 
> Regards
> Mugunthan V N

Sebastian
