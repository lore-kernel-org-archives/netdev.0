From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 14/16] RealView: Use the in-kernel smc911x.c driver on	RealView
Date: Tue, 21 Oct 2008 19:46:53 +0100
Message-ID: <20081021184653.GA15027@flint.arm.linux.org.uk>
References: <1224578293.9330.9.camel@pc1117.cambridge.arm.com> <OF6B543A5F.032D7BBC-ON802574E9.00340E58-802574E9.00396C6E@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Bill Gatliff <bgat@billgatliff.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	linux-arm-kernel@lists.arm.linux.org.uk, Ian.Saturley@smsc.com,
	netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:34979 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbYJUSrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 14:47:33 -0400
Content-Disposition: inline
In-Reply-To: <OF6B543A5F.032D7BBC-ON802574E9.00340E58-802574E9.00396C6E@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 21, 2008 at 11:26:42AM +0100, Steve.Glendinning@smsc.com wrote:
> Almost all the feedback I've had has been positive, but I've had a few
> "can't you just fix the in-tree driver?" responses.  The trouble is it's
> not a *small* piece of work!

Which is reasonable given your summary, since...

> smsc911x
> - uses functions instead of macros, making it more readable
> - uses napi (and manages significantly higher throughput because of it)
> - uses phylib
> - passes checkpatch.pl
> - has workarounds for older LAN911x variants
> 
> smc911x
> - is already in-tree (not really technical, but still important)
> - has support for pxa dma*
> - has dynamic bus width config

.. we want to avoid having two drivers for the same device, but not
supporting these features would be seen as a regression.
