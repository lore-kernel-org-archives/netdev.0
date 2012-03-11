From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Fix Smatch warning.
Date: Sun, 11 Mar 2012 15:57:36 -0700 (PDT)
Message-ID: <20120311.155736.298099455288242780.davem@davemloft.net>
References: <4F58041F.5060209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab2CKW5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:57:47 -0400
In-Reply-To: <4F58041F.5060209@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Thu, 08 Mar 2012 08:58:07 +0800

> 
> With commit d6ddef9e641d(IPv6: Fix not join all-router mcast group
> when forwarding set.) I check 'dev' after it's dereference that
> leads to a Smatch complaint:
> 
> net/ipv6/addrconf.c:438 ipv6_add_dev()
> 	 warn: variable dereferenced before check 'dev' (see line 432)
 ...
> Remove the check to avoid the complaint as 'dev' can't be NULL.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied.
