From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] tc: flower: Introduce vlan support
Date: Mon, 29 Aug 2016 11:14:10 -0700
Message-ID: <20160829111410.1a23a4bc@xeon-e3>
References: <1471861494-8299-1-git-send-email-hadarh@mellanox.com>
        <1471861494-8299-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33168 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756229AbcH2SOA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 14:14:00 -0400
Received: by mail-pf0-f174.google.com with SMTP id y134so54358777pfg.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 11:13:59 -0700 (PDT)
In-Reply-To: <1471861494-8299-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Aug 2016 13:24:53 +0300
Hadar Hen Zion <hadarh@mellanox.com> wrote:

> iff --git a/include/linux/tc_act/tc_vlan.h b/include/linux/tc_act/tc_vlan.h
> index 31151ff..26ae695 100644
> --- a/include/linux/tc_act/tc_vlan.h
> +++ b/include/linux/tc_act/tc_vlan.h
> @@ -16,6 +16,9 @@
>  
>  #define TCA_VLAN_ACT_POP	1
>  #define TCA_VLAN_ACT_PUSH	2
> +#define VLAN_PRIO_MASK		0x7
> +#define VLAN_VID_MASK		0x0fff
> +
>  
>  struct tc_vlan {
>  	tc_gen;

I was going to apply this, it looks fine. But there is an issue
you need to address first.

All headers in iproute2 come from sanitized version of the kernel headers.
This header does not match the version in net-next.

net-next$ grep VLAN_PRIO_MASK usr/include/linux/tc_act/tc_vlan.h

Please update the kernel header first, then resubmit the patch.
