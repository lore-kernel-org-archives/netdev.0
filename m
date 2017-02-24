From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vxlan: don't allow overwrite of config src addr
Date: Fri, 24 Feb 2017 13:37:37 -0500 (EST)
Message-ID: <20170224.133737.1079526647474220757.davem@davemloft.net>
References: <1487958431-8115-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brussell@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdBXSrc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 13:47:32 -0500
In-Reply-To: <1487958431-8115-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Russell <brussell@brocade.com>
Date: Fri, 24 Feb 2017 17:47:11 +0000

> When using IPv6 transport and a default dst, a pointer to the configured
> source address is passed into the route lookup. If no source address is
> configured, then the value is overwritten.
> 
> IPv6 route lookup ignores egress ifindex match if the source address is set,
> so if egress ifindex match is desired, the source address must be passed
> as any. The overwrite breaks this for subsequent lookups.
> 
> Avoid this by copying the configured address to an existing stack variable
> and pass a pointer to that instead.
> 
> Fixes: 272d96a5ab10 ("net: vxlan: lwt: Use source ip address during route lookup.")
> 
> Signed-off-by: Brian Russell <brussell@brocade.com>
> Acked-by: Jiri Benc <jbenc@redhat.com>

Applied and queued up for -stable, thanks.
