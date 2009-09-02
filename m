From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: embed ip6_dst_ops directly
Date: Tue, 01 Sep 2009 17:44:17 -0700 (PDT)
Message-ID: <20090901.174417.119983403.davem@davemloft.net>
References: <20090829113449.GA3067@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net,
	dlezcano@fr.ibm.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40463
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755441AbZIBAoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:44:02 -0400
In-Reply-To: <20090829113449.GA3067@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 29 Aug 2009 15:34:49 +0400

> struct net::ipv6.ip6_dst_ops is separatedly dynamically allocated,
> but there is no fundamental reason for it. Embed it directly into
> struct netns_ipv6.
> 
> For that:
> * move struct dst_ops into separate header to fix circular dependencies
> 	I honestly tried not to, it's pretty impossible to do other way
> * drop dynamical allocation, allocate together with netns
> 
> For a change, remove struct dst_ops::dst_net, it's deducible
> by using container_of() given dst_ops pointer.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
