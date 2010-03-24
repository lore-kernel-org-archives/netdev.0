From: David Miller <davem@davemloft.net>
Subject: Re: inet6_ifa_finish_destroy() blurt
Date: Tue, 23 Mar 2010 23:33:48 -0700 (PDT)
Message-ID: <20100323.233348.184444812.davem@davemloft.net>
References: <20100323153520.3869ec5d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39794
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754812Ab0CXGdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:33:25 -0400
In-Reply-To: <20100323153520.3869ec5d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 23 Mar 2010 15:35:20 -0700

> 
> Got this during boot using today's linux-next.  The
> WARN_ON(!hlist_unhashed(&ifp->addr_lst)) triggered. 
> 
> c2e21293c054817c42eb5fa9c613d2ad51954136 ("ipv6: convert addrconf list
> to hlist") added it.

Stephen please look into this.

Thank you.
