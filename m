From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: no more dev_put() in inet6_bind()
Date: Mon, 02 Nov 2009 03:43:07 -0800 (PST)
Message-ID: <20091102.034307.41803444.davem@davemloft.net>
References: <4AEEBE2F.4020005@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754607AbZKBLmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 06:42:43 -0500
In-Reply-To: <4AEEBE2F.4020005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2009 12:10:39 +0100

> Avoids touching device refcount in inet6_bind(), thanks to RCU
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
