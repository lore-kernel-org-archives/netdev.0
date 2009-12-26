From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH 1/4] stmmac: thinking about a generic driver for
 Synopsys Controllers.
Date: Fri, 25 Dec 2009 18:26:45 -0800 (PST)
Message-ID: <20091225.182645.59702958.davem@davemloft.net>
References: <1260948405-28511-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40494
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbZLZC0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 21:26:43 -0500
In-Reply-To: <1260948405-28511-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 16 Dec 2009 08:26:42 +0100

> The idea behind this patch is to start thinking about a
> generic driver for Synopsys Ethernet Controllers
> starting from the stmmac device driver.

This patch does too much at once.

It changes Kconfig help test.

It moves many things around to many new files.

It's therefore too large to review as a unit.

Please split this up into several (many) pieces.
One for each specific action.

One patch might improve the help test.  Another might
move DMA operations out to a seperate file, another might
move another class of operations into a new file.

And at each step of the way the driver must compile and work
properly.

Thanks.
