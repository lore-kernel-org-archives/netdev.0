From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: undo_retrans counter fixes
Date: Mon, 07 Feb 2011 15:05:22 -0800 (PST)
Message-ID: <20110207.150522.28821840.davem@davemloft.net>
References: <1297119424-19956-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36587
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753313Ab1BGXEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 18:04:47 -0500
In-Reply-To: <1297119424-19956-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon,  7 Feb 2011 14:57:04 -0800

> Fix a bug that undo_retrans is incorrectly decremented when undo_marker is
> not set or undo_retrans is already 0. This happens when sender receives
> more DSACK ACKs than packets retransmitted during the current
> undo phase. This may also happen when sender receives DSACK after
> the undo operation is completed or cancelled.
> 
> Fix another bug that undo_retrans is incorrectly incremented when
> sender retransmits an skb and tcp_skb_pcount(skb) > 1 (TSO). This case
> is rare but not impossible.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Looks good, Ilpo could you please review this real quick?

Thanks.
