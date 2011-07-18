From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: save cpu cycles from check_leaf()
Date: Mon, 18 Jul 2011 10:42:03 -0700 (PDT)
Message-ID: <20110718.104203.518080599243849290.davem@davemloft.net>
References: <20110717.122949.1167434585296050332.davem@davemloft.net>
	<1310994993.5756.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666Ab1GRRmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 13:42:09 -0400
In-Reply-To: <1310994993.5756.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 18 Jul 2011 15:16:33 +0200

> [PATCH net-next-2.6] ipv4: save cpu cycles from check_leaf()
> 
> Compiler is not smart enough to avoid double BSWAP instructions in
> ntohl(inet_make_mask(plen)).
> 
> Lets cache this value in struct leaf_info, (fill a hole on 64bit arches)
> 
> With route cache disabled, this saves ~2% of cpu in udpflood bench on
> x86_64 machine.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
