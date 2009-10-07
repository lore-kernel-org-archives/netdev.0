From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use sk_mark for routing lookup in more places
Date: Wed, 07 Oct 2009 01:27:18 -0700 (PDT)
Message-ID: <20091007.012718.194229685.davem@davemloft.net>
References: <4AC4D90E.3040008@gmail.com>
	<20091001.151823.263194343.davem@davemloft.net>
	<4AC58C46.8080408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: atis@mikrotik.com, panther@balabit.hu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758799AbZJGI1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:27:23 -0400
In-Reply-To: <4AC58C46.8080408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Oct 2009 07:14:46 +0200

> Here is a followup on this area, thanks.
> 
> [RFC] af_packet: fill skb->mark at xmit
> 
> skb->mark may be used by classifiers, so fill it in case user 
> set a SO_MARK option on socket.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks fine, applied, thanks!
