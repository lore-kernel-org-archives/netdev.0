From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Mon, 23 Feb 2015 16:48:01 -0500 (EST)
Message-ID: <20150223.164801.842537100812023841.davem@davemloft.net>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	<1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	<20150223205633.7fbd08d4@halley>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eyal.birger@gmail.com, edumazet@google.com, netdev@vger.kernel.org
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbbBWVsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 16:48:04 -0500
In-Reply-To: <20150223205633.7fbd08d4@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Mon, 23 Feb 2015 20:56:33 +0200

> May I suggest to unalias 'mark' out of the union?

Only in exchange for finding a way to remove completely another object
of the same size from sk_buff.

I refuse to let it grow any more, it's already way too big.
