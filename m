From: Timur Tabi <B04825@freescale.com>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Wed, 24 Oct 2012 14:12:55 -0500
Message-ID: <50883DB7.4030502@freescale.com>
References: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com> <6AE080B68D46FC4BA2D2769E68D765B70810B134@039-SN2MPN1-023.039d.mgd.msft.net> <50883D03.1000600@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Yang <Wei.Yang@windriver.com>,
	Manoil Claudiu-B08782 <B08782@freescale.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.186] ([216.32.180.186]:14957 "EHLO
	co1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030213Ab2JXTOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 15:14:08 -0400
In-Reply-To: <50883D03.1000600@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker wrote:
> Even if it makes sense to convert the driver to of_xxx calls,
> I think the obvious bug should be fixed as a separate commit,
> so that the -stable folks have something to cherry pick.

Oh, I agree with that.  I was just wondering why an OF-enabled driver
would not use OF calls.  I've never seen that before.  My instinct is that
the original developer had no idea what he was doing, but perhaps there is
a very good reason for the way the driver is written.

-- 
Timur Tabi
Linux kernel developer at Freescale
