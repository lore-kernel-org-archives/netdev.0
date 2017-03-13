From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/2] mpls: allow TTL propagation to/from IP
 packets to be configured
Date: Mon, 13 Mar 2017 13:28:59 -0700
Message-ID: <58C7010B.2010609@cumulusnetworks.com>
References: <1488933990-14490-1-git-send-email-rshearma@brocade.com> <1489178605-30027-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34282 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752994AbdCMU3C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 16:29:02 -0400
Received: by mail-pg0-f49.google.com with SMTP id 77so69173583pgc.1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 13:29:01 -0700 (PDT)
In-Reply-To: <1489178605-30027-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/10/17, 12:43 PM, Robert Shearman wrote:
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
>
> Robert Shearman (2):
>   mpls: allow TTL propagation to IP packets to be configured
>   mpls: allow TTL propagation from IP packets to be configured
>
>  
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
