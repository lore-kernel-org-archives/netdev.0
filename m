From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: MACH_QQ2440 (and CS890x)
Date: Fri, 25 Nov 2011 10:46:26 +0100
Message-ID: <1322214386.25125.127.camel@x61.thuisdomein>
References: <1322169455.25125.104.camel@x61.thuisdomein>
	 <20111125093651.GA10636@glitch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, kernel@pengutronix.de
To: Domenico Andreoli <cavokz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:60083 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab1KYJqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 04:46:38 -0500
In-Reply-To: <20111125093651.GA10636@glitch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Canned message follows.)

On Fri, 2011-11-25 at 10:36 +0100, Domenico Andreoli wrote:
> On Thu, Nov 24, 2011 at 10:17:35PM +0100, Paul Bolle wrote:
> > 3) Are there any plans to add a Kconfig entry for MACH_QQ2440? If not,
> > should I submit the (trivial) patch to drop that Kconfig symbol and that
> > preprocessor macro?
> 
> The plan for qq2440 is to use the cs890x platform driver which is being
> developed by Jaccon [0], maybe in the OF variant.  I already asked him
> to remove these specific and unused macros for me.
> 
> So thank you for the offer but I hope the work of Jaccon will be
> merged soon.

Thanks. I'll stop worrying about this invalid Kconfig dependency for
now. It might pop up again if I ever decide to scan the mainline tree
for invalid symbols again. We'll see.


Paul Bolle
