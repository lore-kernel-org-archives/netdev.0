From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: sr: fix IPv6 initialization failure
 without lwtunnels
Date: Tue, 15 Nov 2016 10:18:57 -0500 (EST)
Message-ID: <20161115.101857.1945116546500210861.davem@davemloft.net>
References: <5828C619.2020008@uclouvain.be>
        <5829C89B.7010405@cumulusnetworks.com>
        <582AE0B0.60006@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
        lorenzo@google.com
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54512 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752232AbcKOPS7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 10:18:59 -0500
In-Reply-To: <582AE0B0.60006@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Tue, 15 Nov 2016 11:17:20 +0100

> On 11/14/2016 03:22 PM, Roopa Prabhu wrote:
>> I prefer option b). most LWTUNNEL encaps are done this way.
>> 
>> seg6 and seg6_iptunnel is new segment routing code and can be under
>> CONFIG_IPV6_SEG6 which depends on CONFIG_LWTUNNEL and CONFIG_IPV6.
>> CONFIG_IPV6_SEG6_HMAC could then depend on CONFIG_IPV6_SEG6
> 
> Will do that, thanks

This is good for the time being.

Although I'd like to entertain the idea of making LWTUNNEL
unconditionally built and considered a fundamental piece of
networking infrastructure just like net/core/dst.c
