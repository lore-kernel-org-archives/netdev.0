From: David Miller <davem@davemloft.net>
Subject: Re: [NET] [Patch 0/4]: Removing some redundancies in skbuff.h
Date: Sun, 13 Apr 2008 23:44:53 -0700 (PDT)
Message-ID: <20080413.234453.118301281.davem@davemloft.net>
References: <skbuff_h_small_patchset>
	<1208153470-9847-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753500AbYDNGov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:44:51 -0400
In-Reply-To: <1208153470-9847-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 14 Apr 2008 07:11:06 +0100

> This is a small set of tiny patches reducing duplications in skbuff.h.
> 
> They can be seen as one single patch, but split apart it is more immediate
> to see what they do.
> 
> Patch #1: Expresses __skb_dequeue     in terms of skb_peek and __skb_unlink.
> Patch #2: Expresses __skb_queue_after in terms of __skb_insert. 
> Patch #3: Expresses   skb_append      in terms of __skb_queue_after.
> Patch #4: Expresses __skb_queue_tail  in terms of __skb_insert.
> 
> Also removed a comment 'XXX more streamlined implementation'.

These don't apply to net-2.6.26, which is where I'd like to apply them.

Please respin, thank you.
