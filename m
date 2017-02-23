From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 12:54:01 -0500 (EST)
Message-ID: <20170223.125401.1794857404908689667.davem@davemloft.net>
References: <635223204.206529.1487859673545.JavaMail.zimbra@tpip.net>
        <20170223164229.GA4996@salvia>
        <109485900.208950.1487870356640.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, tom@herbertland.com, gerlitz.or@gmail.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, laforge@gnumonks.org,
        netdev@vger.kernel.org
To: aschultz@tpip.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdBWRyE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 12:54:04 -0500
In-Reply-To: <109485900.208950.1487870356640.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schultz <aschultz@tpip.net>
Date: Thu, 23 Feb 2017 18:19:16 +0100 (CET)

> When we are talking about the xmit path, then currently none of the
> receivers we are talking to is going to be Linux and we have no
> idea how they will behave nor do we have any influence on them. Do
> we really need to make assumptions about other vendors implementations?
> 
> Traces on live GRX networks show that about 90% of the SGSN/S-GW
> that would talk to us always use the default GTP-U port as source
> port. Some multi chassis GSN's seem to assign source port ranges to
> chassis, but that has nothing todo with DDOS protection.

This is exactly what other UDP tunnel implementations did before
flow separation was prevelant.

I don't see the point of any of this discussion discouraging the
enablement of proper flow separation.
