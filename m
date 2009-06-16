From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] udp: remove unused union in udp_skb_cb.
Date: Tue, 16 Jun 2009 02:40:58 -0700 (PDT)
Message-ID: <20090616.024058.209622628.davem@davemloft.net>
References: <eb3ff54b0906160150n74fb8984u84a366f5e472b4c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45137
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752700AbZFPJkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:40:55 -0400
In-Reply-To: <eb3ff54b0906160150n74fb8984u84a366f5e472b4c3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Tue, 16 Jun 2009 11:50:11 +0300

> This cleanup patch removes an unused union (header) in udp_skb_cb.
> (include/net/udp.h)

It is used Rami.  The layer above UDP packet processing used
IPSKB() and the ipv6 variant (I forget what it's called) so
we have to take care not to write over that layer's recorded
values in the skb->cb[]
