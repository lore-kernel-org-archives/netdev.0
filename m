From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the
 passive open side
Date: Wed, 08 Jun 2011 17:06:22 -0700 (PDT)
Message-ID: <20110608.170622.443237000314177581.davem@davemloft.net>
References: <1307567318-26760-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hagen@jauu.net, tsunanet@gmail.com,
	netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab1FIAGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 20:06:31 -0400
In-Reply-To: <1307567318-26760-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Wed,  8 Jun 2011 14:08:38 -0700

> From: Jerry Chu <hkchu@google.com>
> 
> This patch lowers the default initRTO from 3secs to 1sec per
> RFC2988bis. It falls back to 3secs if the SYN or SYN-ACK packet
> has been retransmitted, AND the TCP timestamp option is not on.
> 
> It also adds support to take RTT sample during 3WHS on the passive
> open side, just like its active open counterpart, and uses it, if
> valid, to seed the initRTO for the data transmission phase.
> 
> The patch also resets ssthresh to its initial default at the
> beginning of the data transmission phase, and reduces cwnd to 1 if
> there has been MORE THAN ONE retransmission during 3WHS per RFC5681.
> 
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>

Ok, I'll apply this to net-next-2.6

We can add any necessary follow-on tweaks.

Thanks!
