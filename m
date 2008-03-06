From: David Miller <davem@davemloft.net>
Subject: Re: [RE(*2)SEND/patch 2.6.25-rc2-git] net/enc28j60: oops fix
Date: Wed, 05 Mar 2008 18:52:16 -0800 (PST)
Message-ID: <20080305.185216.113979641.davem@davemloft.net>
References: <20080206173342.21CDF8E152@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
	<47AADC51.8060401@eptar.com>
	<200803041717.32868.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lanconelli.claudio@eptar.com
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42271
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755643AbYCFCwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 21:52:16 -0500
In-Reply-To: <200803041717.32868.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Tue, 4 Mar 2008 17:17:32 -0800

> Seems the enc28j60 patches didn't get picked up, ergo (2x) resend...
> they're not in net-2.6.git, even this oops fix (which I'd expect
> would be prioritized for 2.6.25)

We prioritize them about the same as bootup hard hangs with EHCI.

> Subject: [RE(*2)SEND/patch 2.6.25-rc2-git] net/enc28j60: oops fix
> 
> Prevent oops on enc28j60 packet RX:  make sure buffers are aligned.
> Not all architectures support unaligned accesses in kernel space.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>

Applied.
