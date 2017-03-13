From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] mpls: allow TTL propagation to/from IP
 packets to be configured
Date: Mon, 13 Mar 2017 15:29:41 -0700 (PDT)
Message-ID: <20170313.152941.76943783138869668.davem@davemloft.net>
References: <1488933990-14490-1-git-send-email-rshearma@brocade.com>
        <1489178605-30027-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753501AbdCMW3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 18:29:43 -0400
In-Reply-To: <1489178605-30027-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Fri, 10 Mar 2017 20:43:23 +0000

> It is sometimes desirable to present an MPLS transport network as a
> single hop to traffic transiting it because it prevents confusion when
> diagnosing failures. An example of where confusion can be generated is
> when addresses used in the provider network overlap with addresses in
> the overlay network and the addresses get exposed through ICMP errors
> generated as packets transit the provider network.
> 
> In addition, RFC 3443 defines two methods of deriving TTL for an
> outgoing packet: Uniform Model where the TTL is propagated to/from the
> MPLS header and both Pipe Models and Short Pipe Models (with and
> without PHP) where the TTL is not propagated to/from the MPLS header.
> 
> Changes in v3:
>  - decrement ttl on popping last label when not doing ttl propagation,
>    as suggested by David Ahern.
>  - add comment to describe what the somewhat complex conditionals are
>    doing to work out what ttl to use in mpls_iptunnel.c.
>  - rearrange fields fields in struct netns_mpls to keep the platform
>    label fields together, as suggested by David Ahern.
> 
> Changes in v2:
>  - add references to RFC 3443 as suggested by David Ahern
>  - fix setting of skb->protocol as noticed by David Ahern
>  - implement per-route/per-LWT configurability as suggested by Eric
>    Biederman
>  - split into two patches for ease of review

Series applied, thanks.
