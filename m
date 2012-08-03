From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: remove parentheses in return statement
Date: Fri, 03 Aug 2012 16:53:03 -0700 (PDT)
Message-ID: <20120803.165303.1568897713381115598.davem@davemloft.net>
References: <1343985584.9299.873.camel@edumazet-glaptop>
	<20120803.022240.1997423719431165575.davem@davemloft.net>
	<1343987638.9299.912.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sakiwit@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab2HCXxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 19:53:03 -0400
In-Reply-To: <1343987638.9299.912.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Aug 2012 11:53:58 +0200

> We already have such thing in fact : net_hash_mix() which returns 0 if
> NS are not configured.
> 
> (hash_ptr(net,8) is really overkill on 64bit arches)
> 
> High order bits on "struct net *" have absolutely no entropy, unless you
> have a monster machine (more than 256 GB of ram)
> 
> This is the patch I prepared :

Looks good to me.
