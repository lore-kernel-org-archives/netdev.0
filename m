From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: ipv6: ignore null_entry on route dumps
Date: Thu, 26 Jan 2017 18:40:05 -0500 (EST)
Message-ID: <20170126.184005.1132641383010709167.davem@davemloft.net>
References: <1485467648-27922-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaolong.ye@intel.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754014AbdAZXkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 18:40:39 -0500
In-Reply-To: <1485467648-27922-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 26 Jan 2017 13:54:08 -0800

> Dave: per last email you suggested putting this in fib6_dump_node, but
>       fib6_dump_node does not have knowledge of the network namespace
>       because of the way the fib_walker works. I could put
>       struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) w->args;
>       into fib6_dump_node to get the net pointer from it but did not
>       want to duplicate the typecast.

Ok, if you can't see the network namespace in fib6_dump_node() you
can't do the test there.

I'll apply this, thanks.
