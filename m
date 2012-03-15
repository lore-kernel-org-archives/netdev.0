From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.3-rc6 netjet.ko sleeping while in atomic.
Date: Thu, 15 Mar 2012 11:07:33 +0100
Message-ID: <20120315100733.GA6407@electric-eye.fr.zoreil.com>
References: <20120314191650.GB18135@digium.com> <20120315084840.GA20202@gw.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Karsten Keil <kkeil@linux-pingi.de>, netdev@vger.kernel.org,
	Shaun Ruffell <sruffell@digium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51425 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757863Ab2COKJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 06:09:08 -0400
Content-Disposition: inline
In-Reply-To: <20120315084840.GA20202@gw.linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten Keil <kkeil@linux-pingi.de> :
> Thanks for the report.
> I will have a look on this.

Beyond the bug in itsel, nj_irq can currently be called just after the
lock release in the first 'if (card->base_s)' bloc from nj_release.
I am not sure this is very safe either. It would imho not hurt to put
the driver in such a position that free_irq gets called sooner.

-- 
Ueimor
