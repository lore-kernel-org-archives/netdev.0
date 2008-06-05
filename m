From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert Ambassador ATM driver to
	request_firmware()
Date: Thu, 05 Jun 2008 19:13:52 +0100
Message-ID: <1212689632.32207.283.camel@pmac.infradead.org>
References: <200806051606.m55G6OTP029329@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Giuliano Procida <gprocida@marge.com>,
	linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49836 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbYFESOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 14:14:00 -0400
In-Reply-To: <200806051606.m55G6OTP029329@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-06-05 at 12:06 -0400, Chas Williams (CONTRACTOR) wrote:
> along the same lines, this patch removes the pca200e/sba200e firmware
> from the kernel.

Ah, that's great, thank you.

>  the firmware will be in the next release of the userspace atm tools.
> i could move the ambassador firmware there as well if you would like.

For now, I'm keen to keep the firmware within the kernel, in the
firmware/ directory where it can be included directly with no
'regressions'. I don't want the potential debate about firmware being in
the kernel tree to get in the way of the real cleanups -- so if it's OK
with you, I'll apply your patch and also move the firmware into the
firmware/ directory?

-- 
dwmw2

