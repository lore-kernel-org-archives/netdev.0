From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Thu, 13 Apr 2017 16:01:48 -0400 (EDT)
Message-ID: <20170413.160148.1850150011941347398.davem@davemloft.net>
References: <20170413042036.GA46229@ast-mbp.thefacebook.com>
        <20170413.113722.2174945057832588335.davem@davemloft.net>
        <1492111341.29526.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36222 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755085AbdDMUBw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 16:01:52 -0400
In-Reply-To: <1492111341.29526.5.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 13 Apr 2017 21:22:21 +0200

> OTOH, it might depend on the frame data itself, if the program does
> something like
> 
> xdp->data[xdp->data[0] & 0xf]
> 
> (read or write, doesn't really matter) so then the verifier would have
> to take the maximum possible value there into account.

I am not well versed enough with the verifier to understand exactly
how and to what extent SKB accesses are validated by the verifier.

My, perhaps mistaken, impression is that access range validation is
still at least partially done at run time.
