From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 3/5 v2] net/cpsw: don't rely only on netif_running() to
 check which device is active
Date: Mon, 22 Apr 2013 11:30:28 +0200
Message-ID: <51750334.8050807@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de> <516FDE0A.70504@ti.com> <516FE2AD.2040403@linutronix.de> <51711E0B.4000306@ti.com> <20130422083048.GA8162@linutronix.de> <5174FF93.8070408@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:56793 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400Ab3DVJab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 05:30:31 -0400
In-Reply-To: <5174FF93.8070408@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2013 11:14 AM, Mugunthan V N wrote:
>> How about this?
> If this is the case, then other Ethernet drivers will also have the same
> scenario,
> if it can be fixed in a generic way then i will be good.

Other ethernet drivers know if their device generated an interrupt,
stop the source and schedule napi. But here it could be either the
device or the slave device, right?
After writing this, a better idea idea just bumped into my head.

btw: Any update on http://www.spinics.net/lists/netdev/msg233296.html?

> Regards
> Mugunthan V N

Sebastian
