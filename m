From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] gtp: support multiple APN's per GTP
 endpoint
Date: Tue, 14 Mar 2017 11:32:09 -0700 (PDT)
Message-ID: <20170314.113209.1471920938953197702.davem@davemloft.net>
References: <20170314112548.24027-1-aschultz@tpip.net>
        <20170314114538.GC2992@salvia>
        <2005226672.385248.1489495364893.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, laforge@gnumonks.org,
        osmocom-net-gprs@lists.osmocom.org, netdev@vger.kernel.org,
        Lionel.Gauthier@eurecom.fr
To: aschultz@tpip.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750904AbdCNScL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 14:32:11 -0400
In-Reply-To: <2005226672.385248.1489495364893.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schultz <aschultz@tpip.net>
Date: Tue, 14 Mar 2017 13:42:44 +0100 (CET)

> The specific use case of the API that is no longer supported was never used by
> anyone. The only supported and documented API for the GTP module is libgtpnl.
> libgtpnl has always required the now mandatory fields. Therefor the externally
> supported API does not change.

That's not how kernel development works, sorry.

Any user visible interface the kernel exports is not to be broken,
even if you think you control the one library that makes use of it.

This is especially important for netlink because netlink is more like
a networking protocol, that arbitrary programs can listen to for
events.
