From: Domenico Andreoli <cavokz@gmail.com>
Subject: Re: MACH_QQ2440 (and CS890x)
Date: Fri, 25 Nov 2011 10:36:51 +0100
Message-ID: <20111125093651.GA10636@glitch>
References: <1322169455.25125.104.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, kernel@pengutronix.de
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36855 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab1KYJgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 04:36:54 -0500
Received: by bke11 with SMTP id 11so4119097bke.19
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2011 01:36:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1322169455.25125.104.camel@x61.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Nov 24, 2011 at 10:17:35PM +0100, Paul Bolle wrote:
> 0) Since commit 2ce8c07d63 ("CS89x0: Add networking support for QQ2440")
> the mainline kernel tree uses the Kconfig symbol MACH_QQ2440 and the
> preprocessor macro CONFIG_MACH_QQ24400.

Yes, qq2440 got stuck at the beginning of the ongoing ARM arch
overhaul. I plan to submit it again when the situation settles a bit
and it will be more DT aware. In the meanwhile I'm working on a brand
new bcm4760 DT platform.

> 1) But there's currently no Kconfig entry for MACH_QQ2440. (Neither is
> there a direct definition of the macro CONFIG_MACH_QQ2440.) But a (stub)
> entry for MACH_QQ2440 was added to ARM's mach-types in commit 773e9610a7
> and removed again in commit 6f82f4db80 (which isn't too long after
> 2ce8c07d63).
> 
> 3) Are there any plans to add a Kconfig entry for MACH_QQ2440? If not,
> should I submit the (trivial) patch to drop that Kconfig symbol and that
> preprocessor macro?

The plan for qq2440 is to use the cs890x platform driver which is being
developed by Jaccon [0], maybe in the OF variant.  I already asked him
to remove these specific and unused macros for me.

So thank you for the offer but I hope the work of Jaccon will be
merged soon.

>
> Paul Bolle

cheers,
Domenico

[0] http://patchwork.ozlabs.org/patch/118623/
