From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Allow inet6_dump_addr() to handle more than 64
 addresses
Date: Tue, 10 Nov 2009 22:33:34 -0800 (PST)
Message-ID: <20091110.223334.154961944.davem@davemloft.net>
References: <4AF85401.3020906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59206
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753011AbZKKGdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:33:08 -0500
In-Reply-To: <4AF85401.3020906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Nov 2009 18:40:17 +0100

> Apparently, inet6_dump_addr() is not able to handle more than
> 64 ipv6 addresses per device. We must break from inner loops
> in case skb is full, or else cursor is put at the end of list.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
