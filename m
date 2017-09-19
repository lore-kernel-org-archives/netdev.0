From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 12/14] gtp: Configuration for zero UDP checksum
Date: Mon, 18 Sep 2017 21:24:45 -0700 (PDT)
Message-ID: <20170918.212445.1680068602644706922.davem@davemloft.net>
References: <20170919003904.5124-1-tom@quantonium.net>
        <20170919003904.5124-13-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38752 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdISEYr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 00:24:47 -0400
In-Reply-To: <20170919003904.5124-13-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Mon, 18 Sep 2017 17:39:02 -0700

> Add configuration to control use of zero checksums on transmit for both
> IPv4 and IPv6, and control over accepting zero IPv6 checksums on
> receive.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>

I thought we were trying to move away from this special case of allowing
zero UDP checksums with tunnels, especially for ipv6.
