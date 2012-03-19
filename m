From: David Miller <davem@davemloft.net>
Subject: Re: Improve rds_sendmsg printk
Date: Mon, 19 Mar 2012 18:43:35 -0400 (EDT)
Message-ID: <20120319.184335.1229962428916453634.davem@davemloft.net>
References: <20120319224008.GA23036@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741Ab2CSWnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 18:43:40 -0400
In-Reply-To: <20120319224008.GA23036@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 19 Mar 2012 18:40:09 -0400

> - Given this can be called by any user, prevent them from flooding
>   the logs by using printk_ratelimited
> - Also add a rds: prefix, so it's clear where the message is coming from.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

I think it should be removed entirely, no socket layer outputs
a message for this error and neither should rds.
