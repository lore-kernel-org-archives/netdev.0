From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 15/15] smc: proc-fs interface for smc
 connections
Date: Tue, 27 Sep 2016 22:27:41 -0400 (EDT)
Message-ID: <20160927.222741.584893707513031004.davem@davemloft.net>
References: <20160927164156.26184-1-ubraun@linux.vnet.ibm.com>
        <20160927164156.26184-16-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56058 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756090AbcI1C1r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 22:27:47 -0400
In-Reply-To: <20160927164156.26184-16-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 27 Sep 2016 18:41:56 +0200

> Maintain a list of SMC sockets and display important SMC socket
> information in /proc/net/smc.
> 
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>

Dumping internal tables and information via /procfs is strongly
deprecated.

Please use a more modern mechanism (such as netlink) to expose this
information to the user.

You'll be most likely to succeed in your submission if you make use of
or design a generic facility that allows other drivers similar to
your's to provide this kind of information as well.

I'm sorry if this is frustrating, but this is a huge piece of
infrastructure, therefore you can expect lots of pieces to get
feedback and require changes like this.
