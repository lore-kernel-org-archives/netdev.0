From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] socket: use percpu_add() while updating sockets_in_use
Date: Sat, 04 Apr 2009 16:41:23 -0700 (PDT)
Message-ID: <20090404.164123.96789302.davem@davemloft.net>
References: <49D461F8.20906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42999
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753366AbZDDXle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 19:41:34 -0400
In-Reply-To: <49D461F8.20906@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 02 Apr 2009 08:58:00 +0200

> sock_alloc() currently uses following code to update sockets_in_use
> 
> get_cpu_var(sockets_in_use)++;
> put_cpu_var(sockets_in_use);
> 
> This translates to :
 ...
> While percpu_add(sockets_in_use, 1) translates to a single instruction :
> 
> c0436275:   64 83 05 20 5f 6a c0    addl   $0x1,%fs:0xc06a5f20
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks!
