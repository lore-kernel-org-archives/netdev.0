From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] firmware: convert Ambassador ATM driver to request_firmware()
Date: Thu, 05 Jun 2008 14:20:52 -0400
Message-ID: <200806051820.m55IKqp0031852@cmf.nrl.navy.mil>
References: <1212689632.32207.283.camel@pmac.infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: Giuliano Procida <gprocida@marge.com>,
	linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:38928 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbYFESVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 14:21:46 -0400
Reply-To: chas3@users.sourceforge.net
Reply-To: chas3@users.sourceforge.net
In-reply-to: <1212689632.32207.283.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1212689632.32207.283.camel@pmac.infradead.org>,David Woodhouse writ
es:
>For now, I'm keen to keep the firmware within the kernel, in the
>firmware/ directory where it can be included directly with no
>'regressions'. I don't want the potential debate about firmware being in
>the kernel tree to get in the way of the real cleanups -- so if it's OK
>with you, I'll apply your patch and also move the firmware into the
>firmware/ directory?

it would need to be converted to the binary form first, or the patch
will need to rewritten to use the s-record format.
