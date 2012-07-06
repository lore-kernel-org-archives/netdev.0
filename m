From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv6: Initialize the struct rt6_info
 behind the dst_enty field
Date: Fri, 06 Jul 2012 03:57:39 -0700 (PDT)
Message-ID: <20120706.035739.572666246297042175.davem@davemloft.net>
References: <20120706093709.GH1869@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632Ab2GFK5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 06:57:42 -0400
In-Reply-To: <20120706093709.GH1869@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 6 Jul 2012 11:37:09 +0200

> +		new = (struct dst_entry *)rt;
>  
> -		new = &rt->dst;

Please do not fight the typing system, the existing "net = &rt->dst;"
assignment is the correct way to do this.

The same issue should be fixed in patch #2 as well.

Thank you.
