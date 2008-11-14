From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Thu, 13 Nov 2008 20:40:25 -0800 (PST)
Message-ID: <20081113.204025.162228911.davem@davemloft.net>
References: <b6fcc0a0811131521h69419b4an102a0cee98841a83@mail.gmail.com>
	<491D003F.7060605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751206AbYKNEkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 23:40:32 -0500
In-Reply-To: <491D003F.7060605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 14 Nov 2008 05:36:15 +0100

> This is better because :
> 
> 1) No #ifdef CONFIG_NET_NS
> 
> 2) The magic about &init_net is not duplicated in ten different include files, but
>    centralized in the right file : include/net/net_namespace.h

I %100 agree.
