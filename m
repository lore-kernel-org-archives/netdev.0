From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] can: Use WARN_ONCE() instead of BUG_ON() for
 sanity check in receive path
Date: Wed, 12 Aug 2009 22:01:23 -0700 (PDT)
Message-ID: <20090812.220123.234730484.davem@davemloft.net>
References: <4A80040D.3030009@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, l.fu@pengutronix.de,
	m.olbrich@pengutronix.de, netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41910
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751661AbZHMFBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 01:01:13 -0400
In-Reply-To: <4A80040D.3030009@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Mon, 10 Aug 2009 13:27:09 +0200

> Additionally it changes the return values to the common NET_RX_xxx constants.

Don't munge unrelated changes together like this, split it up.

Also, this is not net-2.6 material, I will only apply these changes
to net-next-2.6 at this point.

Thanks.
