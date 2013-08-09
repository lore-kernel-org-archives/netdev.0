From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 09 Aug 2013 09:59:54 +0900
Message-ID: <001401ce949b$c2937b10$47ba7130$@samsung.com>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
 <20130808210918.GE5502@mwanda>
 <20130808.142054.1541424422807503741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, kumargauravgupta3@gmail.com,
	emilio@elopez.com.ar, mugunthanvnm@ti.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-reply-to: <20130808.142054.1541424422807503741.davem@davemloft.net>
Content-language: ko
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, August 09, 2013 6:21 AM, David Miller wrote:
> On Fri, 9 Aug 2013 00:09:18 +0300, Dan Carpenter wrote:
> > On Fri, Aug 09, 2013 at 12:50:49AM +0530, Kumar Gaurav wrote:
> >> Removed IRQF_DISABLED as it's no-op and should be removed
> >>
> >
> > What?  No, that doesn't sound right.
> 
> The IRQ layer completely ignores the flag for several releases
> now, it's a complete no-op as his commit message so adequately
> states.

Yes, you're right. :-)

Currently, 'IRQF_DISABLED' is deprecated as below.
(include/linux/interrupt.h)
* IRQF_DISABLED - keep irqs disabled when calling the action handler.
*                 DEPRECATED. This flag is a NOOP and scheduled to be removed

Best regards,
Jingoo Han

> 
> So what's the problem again? :-)

