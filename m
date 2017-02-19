From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next repost 0/3] tc: flower: support masked
 ICMP code and type match
Date: Sat, 18 Feb 2017 16:14:24 -0800
Message-ID: <20170218161424.4f0f9a83@xeon-e3>
References: <1486648141-22955-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32846 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750859AbdBSAOc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:14:32 -0500
Received: by mail-pf0-f175.google.com with SMTP id g80so4935089pfb.0
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:14:32 -0800 (PST)
In-Reply-To: <1486648141-22955-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Feb 2017 14:48:58 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Hi,
> 
> this short series allows the tc tool to configure masked matches on the
> ICMP code and type. Unmasked matches are already supported by the tool.
> 
> This does not depend on any kernel changes as support for both masked and
> unmasked matches were added to the kernel at the same time.
> 
> Sample usage:
> 
> tc qdisc add dev eth0 ingress
> tc filter add dev eth0 protocol ipv6 parent ffff: flower \
>         indev eth0 ip_proto icmpv6 type 128/240 code 0 action drop
> 
> Reposting after breaking out of a larger patchset.
> 
> Simon Horman (3):
>   tc: flower: provide generic masked u8 parser helper
>   tc: flower: provide generic masked u8 print helper
>   tc: flower: support masked ICMP code and type match
> 
>  man/man8/tc-flower.8 |  16 ++++--
>  tc/f_flower.c        | 158 ++++++++++++++++++++++++++++++++++-----------------
>  2 files changed, 119 insertions(+), 55 deletions(-)
> 

Applied to net-next
