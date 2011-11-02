From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: fix a race in encap_rcv handling
Date: Wed, 02 Nov 2011 00:51:56 -0400 (EDT)
Message-ID: <20111102.005156.86865779446341817.davem@davemloft.net>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
	<1320188219.4728.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab1KBEv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 00:51:59 -0400
In-Reply-To: <1320188219.4728.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Nov 2011 23:56:59 +0100

> udp_queue_rcv_skb() has a possible race in encap_rcv handling, since
> this pointer can be changed anytime.
> 
> We should use ACCESS_ONCE() to close the race.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks!
