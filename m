From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy_device: Interrupt number 0 is valid
Date: Thu, 09 Oct 2008 09:38:35 -0700 (PDT)
Message-ID: <20081009.093835.27394691.davem@davemloft.net>
References: <48ECA4A0.7080508@teltonika.lt>
	<20081008.094335.216774973.davem@davemloft.net>
	<48EDAD1F.6010109@teltonika.lt>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paulius.zaleckas@teltonika.lt
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52926
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752773AbYJIQi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 12:38:59 -0400
In-Reply-To: <48EDAD1F.6010109@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Date: Thu, 09 Oct 2008 10:05:03 +0300

> David Miller wrote:
> > From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> > Date: Wed, 08 Oct 2008 15:16:32 +0300
> > 
> >> If interrupt number 0(valid interrupt number) will be passed as
> >> phy interrupt it should be used. In current situation even phy
> >> polling will not work since PHY_POLL = -1
> >>
> >> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> > 
> > In the Linux kernel, interrupt number 0 is defined as not valid.
> 
> Where it is defined as not valid?
> Maybe it is not valid under x86, but it is valid at least on
> ARM for sure.

There are many tests in the kernel that explicitly assume
that IRQ zero is not valid.

And architectures should make amends to adhere to this
convention, even if physically IRQ 0 is meaningful for them.
