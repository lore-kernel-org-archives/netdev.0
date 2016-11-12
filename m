From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] tc: flower: Support matching on SCTP ports
Date: Sat, 12 Nov 2016 10:32:09 +0300
Message-ID: <20161112103209.242d3e5e@samsung9>
References: <1478176001-29174-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:35950 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752238AbcKLHcO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 02:32:14 -0500
Received: by mail-lf0-f49.google.com with SMTP id t196so26807657lff.3
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 23:32:13 -0800 (PST)
In-Reply-To: <1478176001-29174-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Nov 2016 13:26:39 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Hi,
> 
> this short series adds support for matching on SCTP ports in the same way
> that matching on TCP and UDP ports is already supported. It corresponds to
> a net-next patch to add the same support to the kernel.
> 
> Example usage:
> 
> tc qdisc add dev eth0 ingress
> 
> tc filter add dev eth0 protocol ip parent ffff: \
>     flower indev eth0 ip_proto sctp dst_port 80 \
>     action drop
> 
> 
> Simon Horman (2):
>   tc: update headers for TCA_FLOWER_KEY_SCTP_*
>   tc: flower: Support matching on SCTP ports
> 
>  include/linux/pkt_cls.h |  5 ++++
>  tc/f_flower.c           | 65 +++++++++++++++++++++++--------------------------
>  2 files changed, 36 insertions(+), 34 deletions(-)
> 

Applied, thanks.
