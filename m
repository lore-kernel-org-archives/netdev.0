From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] ip6: fix PMTU discovery when using /127
 subnets
Date: Sun, 16 Jul 2017 16:37:04 -0700 (PDT)
Message-ID: <20170716.163704.1853816638083095709.davem@davemloft.net>
References: <20170715174020.6691-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org
To: vincent@bernat.im
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdGPXhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 19:37:05 -0400
In-Reply-To: <20170715174020.6691-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <vincent@bernat.im>
Date: Sat, 15 Jul 2017 19:40:20 +0200

> The definition of an "anycast destination address" has been tweaked as a
> side-effect of commit 2647a9b07032 ("ipv6: Remove external dependency on
> rt6i_gateway and RTF_ANYCAST"). The first address of a point-to-point
> /127 subnet is now considered as an anycast address. This prevents
> ICMPv6 errors to be returned to a sender of such a subnet and breaks
> PMTU discovery.
 ...
> Fixes: 2647a9b07032 ("ipv6: Remove external dependency on rt6i_gateway and RTF_ANYCAST")
> Signed-off-by: Vincent Bernat <vincent@bernat.im>

Applied.
