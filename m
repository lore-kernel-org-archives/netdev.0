From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: usbnet: doc updates
Date: Sun, 05 Sep 2010 17:12:27 -0700 (PDT)
Message-ID: <20100905.171227.193704987.davem@davemloft.net>
References: <298165.21593.qm@web180307.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@rainbow-software.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43201
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754270Ab0IFAMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 20:12:10 -0400
In-Reply-To: <298165.21593.qm@web180307.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Sun, 5 Sep 2010 17:06:10 -0700 (PDT)

> Apologies in advance for sending this as an
> attachment, but I think it's less likely to get
> angled (except quoted-printable?) this way.

Well, patchwork didn't grok it at all, and this means your patch is a
lot more work for me.

Actually looking at the patch, the comment formatting is not all
that pretty:

+ * Note that the design center for usbnet has one IEEE packet per URB, and
+maps network TX and RX queues directly to the USB hardware TX/RX queues,

Please start every line of the comment with the
proper leading " * " rather than going straight to
the text.

+	/* fixup rx packet ( by stripping framing from URB/SKB.
+	 *
+	 - If SKB batches one or more packets, pass all but one of them
+	   up the stack (clone SKB and fixup each clone before netif_rx)).

Please also do the same here.
