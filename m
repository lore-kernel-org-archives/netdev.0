From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] asix: check packet size against mtu+ETH_HLEN instead
 of ETH_FRAME_LEN
Date: Mon, 07 Jun 2010 00:57:01 -0700 (PDT)
Message-ID: <20100607.005701.220044418.davem@davemloft.net>
References: <20100606233531.23585.10292.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhollis@davehollis.com
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58098
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752724Ab0FGH4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 03:56:51 -0400
In-Reply-To: <20100606233531.23585.10292.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Date: Mon, 07 Jun 2010 02:35:31 +0300

> Driver checks received packet is too large in asix_rx_fixup() and fails if it is. Problem is
> that MTU might be set larger than 1500 and asix fails to work correctly with VLAN tagged
> packets. The check should be 'dev->net->mtu + ETH_HLEN' instead.
> 
> Tested with AX88772.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Applied, thanks.
