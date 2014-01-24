From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: fix u64 division
Date: Thu, 23 Jan 2014 16:12:01 -0800 (PST)
Message-ID: <20140123.161201.2239098830159792011.davem@davemloft.net>
References: <52E18720.4060008@redhat.com>
	<1390517023-31950-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zoltan.kiss@citrix.com, andy@greyhouse.net,
	vfalico@redhat.com, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbaAXAMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:12:05 -0500
In-Reply-To: <1390517023-31950-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 23 Jan 2014 23:43:43 +0100

> After the option conversion downdelay and updelay divide a u64
> and on a 32 bit this causes the following errors:
> ERROR: "__udivdi3" [drivers/net/bonding/bonding.ko] undefined!
> ERROR: "__umoddi3" [drivers/net/bonding/bonding.ko] undefined!
> 
> Fix it by using a normal int instead because newval->value is capped
> at INT_MAX by the way the option is defined.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

To fix the build I'm applying this, thanks.
