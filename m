From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH/RFC net-next 0/4] net: support MPLS in IPv4 and UDP
Date: Wed, 6 Jul 2016 21:44:13 -0700
Message-ID: <CALx6S36-zs0SEYgKz4koRhsAaadPaWh_w4SYczp_MwxALKqO5w@mail.gmail.com>
References: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35746 "EHLO
	mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbcGGEoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 00:44:14 -0400
Received: by mail-it0-f52.google.com with SMTP id j185so91833111ith.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 21:44:14 -0700 (PDT)
In-Reply-To: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 11:22 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> This short series provides support for MPLS in IPv4 (RFC4023), and by
> virtue of FOU, MPLS in UDP (RFC7510).
>
> The changes are as follows:
> 1. Teach tunnel4.c about AF_MPLS, it already understands AF_INET and
>    AF_INET6
> 2. Enhance IPIP and SIT to handle MPLS. Both already handle IPv4.
>    SIT also already handles IPv6.
> 3. Trivially enhance MPLS to allow routes over SIT and IPIP tunnels.
>

HI Siomon,

Thanks for these patches! Can provide the commands for testing this?

Tom

> A corresponding iproute2 patchset will also be posted.
>
> Simon Horman (4):
>   tunnels: support MPLS over IPv4 tunnels
>   sit: support MPLS over IPv4
>   ipip: support MPLS over IPv4
>   mpls: allow routes on ipip and sit devices
>
>  net/ipv4/ipip.c    | 137 ++++++++++++++++++++++++++++++++++++++++++++++-------
>  net/ipv4/tunnel4.c |  77 ++++++++++++++++++++++++++----
>  net/ipv6/sit.c     |  93 +++++++++++++++++++++++++++++-------
>  net/mpls/af_mpls.c |   6 ++-
>  4 files changed, 269 insertions(+), 44 deletions(-)
>
> --
> 2.7.0.rc3.207.g0ac5344
>
