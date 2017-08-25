From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Add sysctl for per namespace flow label
 reflection
Date: Thu, 24 Aug 2017 18:05:53 -0700 (PDT)
Message-ID: <20170824.180553.1621054459411024798.davem@davemloft.net>
References: <20170823075541.26764-1-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        nikolay@cumulusnetworks.com, tom@herbertland.com
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753556AbdHYBF5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:05:57 -0400
In-Reply-To: <20170823075541.26764-1-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Wed, 23 Aug 2017 09:55:41 +0200

> Reflecting IPv6 Flow Label at server nodes is useful in environments
> that employ multipath routing to load balance the requests. As "IPv6
> Flow Label Reflection" standard draft [1] points out - ICMPv6 PTB error
> messages generated in response to a downstream packets from the server
> can be routed by a load balancer back to the original server without
> looking at transport headers, if the server applies the flow label
> reflection. This enables the Path MTU Discovery past the ECMP router in
> load-balance or anycast environments where each server node is reachable
> by only one path.
> 
> Introduce a sysctl to enable flow label reflection per net namespace for
> all newly created sockets. Same could be earlier achieved only per
> socket by setting the IPV6_FL_F_REFLECT flag for the IPV6_FLOWLABEL_MGR
> socket option.
> 
> [1] https://tools.ietf.org/html/draft-wang-6man-flow-label-reflection-01
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Ok, applied.
