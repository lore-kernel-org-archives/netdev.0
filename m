From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 2/2] mpls: allow TTL propagation from IP
 packets to be configured
Date: Mon, 13 Mar 2017 12:43:06 -0600
Message-ID: <94d59fa1-cd13-5f43-ef1a-188e25f633ed@cumulusnetworks.com>
References: <1488933990-14490-1-git-send-email-rshearma@brocade.com>
 <1489178605-30027-1-git-send-email-rshearma@brocade.com>
 <1489178605-30027-3-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34834 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752385AbdCMSnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:43:09 -0400
Received: by mail-pg0-f53.google.com with SMTP id b129so67328376pgc.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 11:43:08 -0700 (PDT)
In-Reply-To: <1489178605-30027-3-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/10/17 1:43 PM, Robert Shearman wrote:
> Allow TTL propagation from IP packets to MPLS packets to be
> configured. Add a new optional LWT attribute, MPLS_IPTUNNEL_TTL, which
> allows the TTL to be set in the resulting MPLS packet, with the value
> of 0 having the semantics of enabling propagation of the TTL from the
> IP header (i.e. non-zero values disable propagation).
> 
> Also allow the configuration to be overridden globally by reusing the
> same sysctl to control whether the TTL is propagated from IP packets
> into the MPLS header. If the per-LWT attribute is set then it
> overrides the global configuration. If the TTL isn't propagated then a
> default TTL value is used which can be configured via a new sysctl,
> "net.mpls.default_ttl". This is kept separate from the configuration
> of whether IP TTL propagation is enabled as it can be used in the
> future when non-IP payloads are supported (i.e. where there is no
> payload TTL that can be propagated).
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  Documentation/networking/mpls-sysctl.txt |  8 ++++
>  include/net/mpls_iptunnel.h              |  2 +
>  include/net/netns/mpls.h                 |  1 +
>  include/uapi/linux/mpls_iptunnel.h       |  2 +
>  net/mpls/af_mpls.c                       | 11 +++++
>  net/mpls/mpls_iptunnel.c                 | 73 ++++++++++++++++++++++++++------
>  6 files changed, 84 insertions(+), 13 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
Tested-by: David Ahern <dsa@cumulusnetworks.com>
