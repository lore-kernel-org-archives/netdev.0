From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert Ambassador ATM driver to
	request_firmware()
Date: Thu, 05 Jun 2008 19:28:09 +0100
Message-ID: <1212690489.32207.285.camel@pmac.infradead.org>
References: <200806051820.m55IKqp0031852@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Giuliano Procida <gprocida@marge.com>,
	linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48867 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286AbYFES2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 14:28:15 -0400
In-Reply-To: <200806051820.m55IKqp0031852@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-06-05 at 14:20 -0400, Chas Williams (CONTRACTOR) wrote:
> it would need to be converted to the binary form first, or the patch
> will need to rewritten to use the s-record format.

We can do binary form. We just run it through objcopy -Ibinary -Oihex
for convenience of handling it (and that's different to the ones we
actually hand to the kernel in the form of records).

-- 
dwmw2

