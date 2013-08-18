From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set
 was called
Date: Sun, 18 Aug 2013 11:05:03 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308181102230.4089@ionos.tec.linutronix.de>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com> <1375866296-15079-2-git-send-email-fan.du@windriver.com> <52021177.6020306@redhat.com> <520213F2.5090401@windriver.com> <520214C6.6000307@redhat.com> <520B4552.2000607@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Daniel Borkmann <dborkman@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520B4552.2000607@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Aug 2013, Fan Du wrote:

> From e3929d4fdfad5b40fd8cad0e217597670d1aef54 Mon Sep 17 00:00:00 2001
> From: Fan Du <fan.du@windriver.com>
> Date: Wed, 14 Aug 2013 16:39:23 +0800
> Subject: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set was
> called
> 
> When clock_was_set is called in case of system wall time change
> or host resume from suspend state, use this notifier for places
> where interested in this action, e.g Ipsec SA lifetime management.

Sigh. These notifiers have been proposed in the past and we always
rejected them. Why do you need this? There should be nothing except
the core timekeeping code which needs to know about clock_was_set.

Can you please explain what kind of users you have in mind and WHY
they need to know about it.

Thanks,

	tglx
