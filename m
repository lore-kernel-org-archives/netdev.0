From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sk-filter: Add ability to get socket filter
 program
Date: Fri, 26 Oct 2012 15:04:16 -0400 (EDT)
Message-ID: <20121026.150416.1261117140434521260.davem@davemloft.net>
References: <508AC533.4000809@parallels.com>
	<CAD6jFUS9LBtJ20Ty=3LTJNMxb0UhyCxRiAg+T7BUeXGEswpkUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758962Ab2JZTEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 15:04:24 -0400
In-Reply-To: <CAD6jFUS9LBtJ20Ty=3LTJNMxb0UhyCxRiAg+T7BUeXGEswpkUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <danborkmann@iogearbox.net>
Date: Fri, 26 Oct 2012 20:07:13 +0200

> In your commit message, you address how you implement it, but not
> where it could be useful (or ``why one needs it''). For instance, in a
> simple case, you have a packet sniffer that uses PF_PACKET, sets up a
> socket filter and RX_RING, then you start looking at packets and at
> some point you stop and close everything. In which scenario would I
> (ever) call this getsockopt()? (Is it just for the sake for having a
> missing getter-function?)

Everything Pavel is working on is for checkpoint/restart.
