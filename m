From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net, bridge: print log message after state changed
Date: Mon, 14 Nov 2011 06:27:50 -0800
Message-ID: <1321280870.2004.2.camel@Joe-Laptop>
References: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com>
	 <20111114.003702.1097206603722725705.davem@davemloft.net>
	 <1321254211.4072.29.camel@pc005091.de.keymile.net>
	 <20111114.020749.1176229013272872343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang.Fritz@keymile.com, holger.brunck@keymile.com,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37279 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752513Ab1KNO1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 09:27:52 -0500
In-Reply-To: <20111114.020749.1176229013272872343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-14 at 02:07 -0500, David Miller wrote:
> I would never expect an "entering" message to print out after the event
> happens, and in fact I'd _always_ want to see it beforehand so that if
> the state change caused a crash or similar it'd be that much easier
> to pinpoint the proper location.
> 
> I'm still not applying this.  If the other log messages behave
> differently, they are broken, so go fix those instead.

Perhaps use "entered" after the transition or "entering" before.
