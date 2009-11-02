From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: no more dev_put() in
 datagram_send_ctl()
Date: Mon, 02 Nov 2009 03:43:12 -0800 (PST)
Message-ID: <20091102.034312.234006640.davem@davemloft.net>
References: <4AEEC0A2.1070502@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39624
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754501AbZKBLms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 06:42:48 -0500
In-Reply-To: <4AEEC0A2.1070502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2009 12:21:06 +0100

> Avoids touching device refcount in datagram_send_ctl(), thanks to RCU
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
