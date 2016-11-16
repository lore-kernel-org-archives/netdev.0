From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: sr: fix IPv6 initialization failure
 without lwtunnels
Date: Wed, 16 Nov 2016 11:31:52 -0500 (EST)
Message-ID: <20161116.113152.849682693738332064.davem@davemloft.net>
References: <582AE0B0.60006@uclouvain.be>
        <20161115.101857.1945116546500210861.davem@davemloft.net>
        <582C7FFF.70203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.lebrun@uclouvain.be, netdev@vger.kernel.org,
        lorenzo@google.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43758 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932180AbcKPQby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:31:54 -0500
In-Reply-To: <582C7FFF.70203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Wed, 16 Nov 2016 07:49:19 -0800

> On 11/15/16, 7:18 AM, David Miller wrote:
>> Although I'd like to entertain the idea of making LWTUNNEL
>> unconditionally built and considered a fundamental piece of
>> networking infrastructure just like net/core/dst.c
> ok, ack. I can submit a patch for that. But, I had the lwtunnel infra hooks in
> CONFIG_LWTUNNEL to reduce the cost of hooks in the default fast path when it was not enabled.
> Will need to re-evaluate the cost of the hooks in the default fast-path.
 ...
> I am assuming you are ok with various encaps staying in their
> respective configs (mpls iptunnels, ila, and now ipv6 segment
> routing).

Yes.
