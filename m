From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 18:12:02 -0700 (PDT)
Message-ID: <20100926.181202.28824153.davem@davemloft.net>
References: <20100926225440.GH12373@1wt.eu>
	<20100926.160838.246540910.davem@davemloft.net>
	<20100926232530.GK12373@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753486Ab0I0BLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 21:11:42 -0400
In-Reply-To: <20100926232530.GK12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Mon, 27 Sep 2010 01:25:30 +0200

> Agreed. But that's not a reason for killing outgoing data that is
> being sent when there are some data left in the rcv buffer.

What alternative notification to the peer do you suggest other than a
reset, then?  TCP gives us no other.

That's the thing, data integrity is full duplex, thus once it has been
compromised in one direction everything currently in flight must be
zapped.
