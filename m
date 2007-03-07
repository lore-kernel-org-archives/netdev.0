From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : Optimizes inet_getpeer()
Date: Tue, 06 Mar 2007 20:23:36 -0800 (PST)
Message-ID: <20070306.202336.11599348.davem@davemloft.net>
References: <45ED1F35.4070600@cosmosbay.com>
	<20070306.010523.15263796.davem@davemloft.net>
	<200703061133.20389.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51551
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932470AbXCGEXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 23:23:39 -0500
In-Reply-To: <200703061133.20389.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 6 Mar 2007 11:33:20 +0100

> [PATCH] NET : Optimizes inet_getpeer()
> 
> 1) Some sysctl vars are declared __read_mostly
> 
> 2) We can avoid updating stack[] when doing an AVL lookup only.
> 
>     lookup() macro is extended to receive a second parameter, that may be NULL 
> in case of a pure lookup (no need to save the AVL path). This removes 
> unnecessary instructions, because compiler knows if this _stack parameter is 
> NULL or not.
> 
>     text size of net/ipv4/inetpeer.o is 2063 bytes instead of 2107 on x86_64
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
