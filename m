From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: xfrm: Handle errors reported by
 xfrm6_find_1stfragopt()
Date: Fri, 02 Jun 2017 13:57:44 -0400 (EDT)
Message-ID: <20170602.135744.1111064213917464628.davem@davemloft.net>
References: <20170531121541.GA16923@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kraig@google.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdFBR5v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 13:57:51 -0400
In-Reply-To: <20170531121541.GA16923@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 31 May 2017 13:15:41 +0100

> xfrm6_find_1stfragopt() may now return an error code and we must
> not treat it as a length.
> 
> Fixes: 2423496af35d ("ipv6: Prevent overrun when parsing v6 header options")
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied and queued up for -stable, thanks Ben.
