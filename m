From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Thu, 08 Aug 2013 20:10:23 -0700
Message-ID: <1376017823.2087.41.camel@joe-AO722>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
	 <20130808210918.GE5502@mwanda>
	 <20130808.142054.1541424422807503741.davem@davemloft.net>
	 <1375997625.2087.14.camel@joe-AO722> <520452F4.2070804@gmail.com>
	 <1376015984.2087.31.camel@joe-AO722> <520457AD.9060508@gmail.com>
	 <1376016864.2087.34.camel@joe-AO722> <52045B31.9000002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dan.carpenter@oracle.com,
	emilio@elopez.com.ar, mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Kumar Gaurav <kumargauravgupta3@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <52045B31.9000002@gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-08-09 at 08:30 +0530, Kumar Gaurav wrote:
> On Friday 09 August 2013 08:24 AM, Joe Perches wrote:
> > On Fri, 2013-08-09 at 08:15 +0530, Kumar Gaurav wrote:
> >> On Friday 09 August 2013 08:09 AM, Joe Perches wrote:
> > []
> >>> And, maybe it'd be better to use IRQF_TRIGGER_NONE
> >>> instead of 0.
> >> I tried googling what to replace IRQF_DISABLED with but found nothing.
> >> In the patch fixed earlier (not by me) it was replaced with 0 so i did
> >> same. But from now on I'll use IRQF_TRIGGER_NONE. Thanks
> > Maybe that's not the right thing to do.
> > 0 is what's almost exclusively used.
> > IRQF_TRIGGER_NONE is only used a few times.
> > It's also a lot longer.
> >
> Sorry to poke back. But just want to confirm. I should use 
> IRQF_TRIGGER_NONE and not 0 right?

I'd probably just use 0 unless someone wants to
chime in otherwise with some compelling argument.

It'd be pretty easy to mechanically change any
	request_irq(,, 0,
to
	request_irq(,, IRQF_TRIGGER_NONE,
if that's what people want.

(and all the other types of irq requests too)


