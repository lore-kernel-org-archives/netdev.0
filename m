From: David Miller <davem@davemloft.net>
Subject: Re: RX/close vcc race with solos/atmtcp/usbatm/he
Date: Fri, 28 May 2010 03:46:28 -0700 (PDT)
Message-ID: <20100528.034628.200383563.davem@davemloft.net>
References: <1274872584.20576.13579.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	nathan@traverse.com.au
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45747
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754626Ab0E1KqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 06:46:19 -0400
In-Reply-To: <1274872584.20576.13579.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 26 May 2010 12:16:24 +0100

> Can anyone see a better approach -- short of rewriting the whole ATM
> layer to make the locking saner?

There is no doubt in my mind that these VCC objects need to be
refcounted when used like this.

The only other alternative is to make use of something like RCU.
