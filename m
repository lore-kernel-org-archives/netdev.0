From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports
 for bridging device
Date: Wed, 25 Mar 2009 14:35:58 -0700 (PDT)
Message-ID: <20090325.143558.35670359.davem@davemloft.net>
References: <20090323085122.4c9d21f2@nehalam>
	<20090323.152028.205335400.davem@davemloft.net>
	<2a27d3730903250143u58a3c67dp132a8a5755d50d93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37779
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752145AbZCYVgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 17:36:10 -0400
In-Reply-To: <2a27d3730903250143u58a3c67dp132a8a5755d50d93@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yang <leoli@freescale.com>
Date: Wed, 25 Mar 2009 16:43:53 +0800

> Dynamically adjusting is a good idea, but the rx_alloc_extra can only
> go up not the other way down in your code.

That's not a problem.

> Another thought is that if you re-allocate skb here the driver would
> be saved from checking the headroom in the fastpath, am I right?

You're going to need it for other paths.  There are other kinds of
tunnels et al. that eat that headroom space on you.
