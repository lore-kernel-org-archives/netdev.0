From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: fix l3slave check for index returned in
 IP_PKTINFO
Date: Fri, 15 Sep 2017 14:28:28 -0700 (PDT)
Message-ID: <20170915.142828.1798273959011613150.davem@davemloft.net>
References: <1505347897-27422-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57318 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdIOV23 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 17:28:29 -0400
In-Reply-To: <1505347897-27422-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 13 Sep 2017 17:11:37 -0700

> rt_iif is only set to the actual egress device for the output path. The
> recent change to consider the l3slave flag when returning IP_PKTINFO
> works for local traffic (the correct device index is returned), but it
> broke the more typical use case of packets received from a remote host
> always returning the VRF index rather than the original ingress device.
> Update the fixup to consider l3slave and rt_iif actually getting set.
> 
> Fixes: 1dfa76390bf05 ("net: ipv4: add check for l3slave for index returned in IP_PKTINFO")
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied, thanks David.
