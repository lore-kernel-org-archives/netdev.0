From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Wed, 24 Oct 2012 15:11:09 -0500
Message-ID: <50884B5D.9030009@freescale.com>
References: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com> <6AE080B68D46FC4BA2D2769E68D765B70810B134@039-SN2MPN1-023.039d.mgd.msft.net> <50883D03.1000600@windriver.com> <50883DB7.4030502@freescale.com> <20121024194207.GA2732@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Yang <Wei.Yang@windriver.com>,
	Manoil Claudiu-B08782 <B08782@freescale.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:27508
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756093Ab2JXULN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 16:11:13 -0400
In-Reply-To: <20121024194207.GA2732@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
>> > Oh, I agree with that.  I was just wondering why an OF-enabled driver
>> > would not use OF calls.  I've never seen that before.  My instinct is that
>> > the original developer had no idea what he was doing, but perhaps there is
>> > a very good reason for the way the driver is written.

> Instead of using your instinct, try using your brain instead.

Well, as you are obviously so much smarter than I am, how about
enlightening me?  I do not see any explanations in the original commit,
and I do not know why someone would use non-OF calls to get data from the
device tree.  I didn't even know that you could use platform_get_irq() to
get the virtual IRQ from a device tree.

-- 
Timur Tabi
Linux kernel developer at Freescale
