From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
Date: Wed, 06 Apr 2011 11:17:12 -0700 (PDT)
Message-ID: <20110406.111712.226782643.davem@davemloft.net>
References: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com>
	<1302113253.3209.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36603
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755508Ab1DFSRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:17:48 -0400
In-Reply-To: <1302113253.3209.126.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Apr 2011 20:07:33 +0200

> This is why we used on ipv4 :
> 
> if (inet_sk(sk)->inet_daddr)
> 	sock_rps_save_rxhash(sk, skb->rxhash);
> 
> 
> Only arm RFS on UDP if socket is bound to a given remote peer.

Agreed, Neil please make this change to your ipv6 code.

Thanks!
