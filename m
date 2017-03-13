From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 1/2] mpls: allow TTL propagation to IP packets
 to be configured
Date: Mon, 13 Mar 2017 12:42:44 -0600
Message-ID: <9625c915-eec4-8777-333e-4ac18b85872e@cumulusnetworks.com>
References: <1488933990-14490-1-git-send-email-rshearma@brocade.com>
 <1489178605-30027-1-git-send-email-rshearma@brocade.com>
 <1489178605-30027-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35697 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752385AbdCMSmr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:42:47 -0400
Received: by mail-pg0-f43.google.com with SMTP id b129so67320991pgc.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 11:42:46 -0700 (PDT)
In-Reply-To: <1489178605-30027-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/10/17 1:43 PM, Robert Shearman wrote:
> Provide the ability to control on a per-route basis whether the TTL
> value from an MPLS packet is propagated to an IPv4/IPv6 packet when
> the last label is popped as per the theoretical model in RFC 3443
> through a new route attribute, RTA_TTL_PROPAGATE which can be 0 to
> mean disable propagation and 1 to mean enable propagation.
> 
> In order to provide the ability to change the behaviour for packets
> arriving with IPv4/IPv6 Explicit Null labels and to provide an easy
> way for a user to change the behaviour for all existing routes without
> having to reprogram them, a global knob is provided. This is done
> through the addition of a new per-namespace sysctl,
> "net.mpls.ip_ttl_propagate", which defaults to enabled. If the
> per-route attribute is set (either enabled or disabled) then it
> overrides the global configuration.
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  Documentation/networking/mpls-sysctl.txt | 11 ++++
>  include/net/netns/mpls.h                 |  2 +
>  include/uapi/linux/rtnetlink.h           |  1 +
>  net/mpls/af_mpls.c                       | 87 +++++++++++++++++++++++++++++---
>  net/mpls/internal.h                      |  7 +++
>  5 files changed, 100 insertions(+), 8 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
Tested-by: David Ahern <dsa@cumulusnetworks.com>
