From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/15] dec netdev: relocate DIGITAL based drivers to
 legacy
Date: Thu, 28 Oct 2010 22:53:26 -0700 (PDT)
Message-ID: <20101028.225326.183057622.davem@davemloft.net>
References: <20101028.212939.189691515.davem@davemloft.net>
	<alpine.LFD.2.00.1010290545270.25426@eddie.linux-mips.org>
	<alpine.LFD.2.00.1010290629450.25426@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45243
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751777Ab0J2FxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 01:53:03 -0400
In-Reply-To: <alpine.LFD.2.00.1010290629450.25426@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Fri, 29 Oct 2010 06:46:13 +0100 (BST)

>  This would be no different to what we do wrt network protocols under 
> net/, so drivers would go to ethernet/, fasteth/, gbeth/, 10gbeth/, fddi/, 
> tokenring/, atm/, appletalk/, etc. (names up to debate if need be) as 
> applicable.  This would scale well, avoid the need for arbitrary decisions 
> (is this piece legacy yet or not?) and automatically classify drivers as 
> more or less obsolescent too, as obviously none of the stuff under 
> ethernet/, fddi/ or tokenring/ can be reasonably recent unlike 10gbeth/.

Why are you so hung up about something being called legacy?

I would be proud to be labelled "legacy", as that means I've served a
purpose for a long time and some folks even want or need me to stick
around for a bit longer.

Legacy hardware is just old and the drivers for them are in a purely
"sustaining" state, that is all.

And using link layer technology to classify is really stupid since
many devices match multiple of the categories you've suggested.

I think the existing proposal is just fine.
