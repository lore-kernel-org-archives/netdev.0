From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppoe: fix /proc/net/pppoe
Date: Thu, 30 Jul 2009 14:19:30 -0700 (PDT)
Message-ID: <20090730.141930.231068249.davem@davemloft.net>
References: <4A6F017B.4060909@gmail.com>
	<4A6F397D.6010606@gmail.com>
	<4A7019AC.5000402@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, for.poige+bugzilla.kernel.org@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	gorcunov@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42683
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbZG3VTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 17:19:23 -0400
In-Reply-To: <4A7019AC.5000402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Jul 2009 11:43:08 +0200

> If a socket is hashed in last slot of pppoe hash table (PPPOE_HASH_SIZE-1)
> we report it many times (up to filling seq buffer)
> (Only the last socket of last slot)
> 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
