From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ifb error path loop fix
Date: Tue, 02 Jan 2007 15:20:37 -0800 (PST)
Message-ID: <20070102.152037.39159030.davem@davemloft.net>
References: <200701020055.51805.m.kozlowski@tuxland.pl>
	<20070101.235132.85409619.davem@davemloft.net>
	<200701021149.43365.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965026AbXABXUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 18:20:37 -0500
To: m.kozlowski@tuxland.pl
In-Reply-To: <200701021149.43365.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Date: Tue, 2 Jan 2007 11:49:42 +0100

> Hello David, 
> 
> > One could argue from a defensive programming perspective that
> > this bug comes from the fact that the ifb_init_one() loop
> > advances state before checking for errors ('i' is advanced before
> > the 'err' check due to the loop construct), and that's why the
> > error recovery code had to be coded specially :-)
> 
> Now when I look at it I might be wrong and it is not a bug at all. 
> It's just coded in weird way. Anyway isn't there kfree(ifbs) missing
> on error path?
> 
> The patch below should clear things a bit (against plain 2.6.20-rc2-mm1).
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

Ok, I've removed the original patch from my tree.

I'll let this cleanup sit for a while so others can review
it :-)
