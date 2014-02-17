From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 17 Feb 2014 14:06:53 -0500 (EST)
Message-ID: <20140217.140653.1309552047403078220.davem@davemloft.net>
References: <1392656174-14791-4-git-send-email-sw@simonwunderlich.de>
	<5302474B.6090609@broadcom.com>
	<D53252F45158EF44B1DF124FDC9AF2A35AD9E12C@FEYNMAN.fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arend@broadcom.com, sw@simonwunderlich.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: mathias.kretschmer@fokus.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbaBQTHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:07:00 -0500
In-Reply-To: <D53252F45158EF44B1DF124FDC9AF2A35AD9E12C@FEYNMAN.fokus.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kretschmer, Mathias" <mathias.kretschmer@fokus.fraunhofer.de>
Date: Mon, 17 Feb 2014 17:34:34 +0000

> Thought so, as well. But it seems that skb->protocol is not properly
> set when the packet originates from a packet socket.  And in our
> case we cannot set it to a fixed etherType in the bind() call since
> we use three different etherTypes on the same socket.

So many things break if the skb->protocol isn't set correctly that I
would consider such SKBs mal-formed.

You can specify the protocol number in the msghdr passed into the
send.
