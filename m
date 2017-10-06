From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/7] nfp: extend match and action for flower offload
Date: Fri, 6 Oct 2017 08:34:59 -0700
Message-ID: <CALx6S36zb=V3Uv1xxjQi04TaPre7GRyYQ1Wcx_7zd96nSpu3pg@mail.gmail.com>
References: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:48966 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752518AbdJFPfB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 11:35:01 -0400
Received: by mail-qt0-f193.google.com with SMTP id d13so31444523qta.5
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 08:35:00 -0700 (PDT)
In-Reply-To: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon,

Maybe a bit off topic, but I had the impression netronome would
support BPF so that filters could be programmed for arbitrary
protocols and fields. Is that true? If so, what is the relationship
between that functionality and these patches?

Thanks,
Tom

On Fri, Oct 6, 2017 at 1:21 AM, Simon Horman <simon.horman@netronome.com> wrote:
> Pieter says:
>
> This series extends flower offload match and action capabilities. It
> specifically adds offload capabilities for matching on MPLS, TTL, TOS
> and flow label. Furthermore offload capabilities for action have been
> expanded to include set ethernet, ipv4, ipv6, tcp and udp headers.
>
> Pieter Jansen van Vuuren (7):
>   nfp: add mpls match offloading support
>   nfp: add IPv4 ttl and tos match offloading support
>   nfp: add IPv6 ttl and tos match offloading support
>   nfp: add set ethernet header action flower offload
>   nfp: add set ipv4 header action flower offload
>   nfp: add set ipv6 source and destination address
>   nfp: add set tcp and udp header action flower offload
>
>  drivers/net/ethernet/netronome/nfp/flower/action.c | 245 +++++++++++++++++++++
>  drivers/net/ethernet/netronome/nfp/flower/cmsg.h   |  43 ++++
>  drivers/net/ethernet/netronome/nfp/flower/match.c  |  39 +++-
>  .../net/ethernet/netronome/nfp/flower/offload.c    |  20 +-
>  4 files changed, 324 insertions(+), 23 deletions(-)
>
> --
> 2.1.4
>
