From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 14/16] RealView: Use the in-kernel smc911x.c driver on	RealView
Date: Tue, 21 Oct 2008 19:48:38 +0100
Message-ID: <20081021184838.GB15027@flint.arm.linux.org.uk>
References: <OF6B543A5F.032D7BBC-ON802574E9.00340E58-802574E9.00396C6E@smsc.com> <1224585726.9330.22.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve.Glendinning@smsc.com, Bill Gatliff <bgat@billgatliff.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	linux-arm-kernel@lists.arm.linux.org.uk, Ian.Saturley@smsc.com,
	netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:34986 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbYJUStE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 14:49:04 -0400
Content-Disposition: inline
In-Reply-To: <1224585726.9330.22.camel@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 21, 2008 at 11:42:06AM +0100, Catalin Marinas wrote:
> Can we not have both drivers in the kernel until the transition to the
> new one has finished? We seem to still have both eepro100.c and e100.c
> in the kernel targeting similar chips.

There has been several concerted efforts to eliminating one or other.
The problem is that eepro100.c works on some platform/chip combinations
that e100.c doesn't and, probably, vice versa.  So, removing either
causes people regressions.

That's the problem with merging two drivers, and then trying to remove
one later - the hardware they support diverges and then you need to
keep and maintain both.
