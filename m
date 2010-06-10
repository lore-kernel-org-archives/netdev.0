From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH v3] netfilter: Xtables: idletimer target implementation
Date: Thu, 10 Jun 2010 17:55:19 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006101752280.15005@obet.zrqbmnf.qr>
References: <1275592445-15555-1-git-send-email-luciano.coelho@nokia.com>  <4C0F9B17.10504@trash.net> <1276096275.31892.117.camel@chilepepper>  <alpine.LSU.2.01.1006091716170.30265@obet.zrqbmnf.qr>  <1276105707.11199.12.camel@powerslave>
 <1276108939.11199.23.camel@powerslave>  <4C10B954.9080603@trash.net>  <1276173733.5453.1.camel@chilepepper> <1276176776.5453.4.camel@chilepepper>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276176776.5453.4.camel@chilepepper>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-06-10 15:32, Luciano Coelho wrote:
>
>> I also agree that it makes more sense to lookup and store the timer in
>> the targe.
>
>One quick question about this: did you mean to put it in the target info
>structure, in this case struct idletimer_tg_info? So is it okay to have
>internal data in this structure even though it is mostly for passing
>data from the userspace to the kernel?

You put a kernel-private pointer inside idletimer_tginfo,
similar to what other modules do.
That would also allow you to get a reference to the timer
so that you do not have to call find_by_label on every
idletimer_target invocation.
