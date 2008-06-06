From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] firmware: convert Ambassador ATM driver to request_firmware()
Date: Fri, 06 Jun 2008 12:06:46 -0400
Message-ID: <200806061606.m56G6kiH008958@cmf.nrl.navy.mil>
References: <1212690489.32207.285.camel@pmac.infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: Giuliano Procida <gprocida@marge.com>,
	linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:53115 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbYFFQHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 12:07:09 -0400
Reply-To: chas3@users.sourceforge.net
Reply-To: chas3@users.sourceforge.net
In-reply-to: <1212690489.32207.285.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1212690489.32207.285.camel@pmac.infradead.org>,David Woodhouse writ
es:
>On Thu, 2008-06-05 at 14:20 -0400, Chas Williams (CONTRACTOR) wrote:
>> it would need to be converted to the binary form first, or the patch
>> will need to rewritten to use the s-record format.
>
>We can do binary form. We just run it through objcopy -Ibinary -Oihex
>for convenience of handling it (and that's different to the ones we
>actually hand to the kernel in the form of records).

i guess whatever you want to do.  it is just as easy to distribute
the firmware with the atm tools.  it would also ease your gpl concerns
which you noted in your first message.
