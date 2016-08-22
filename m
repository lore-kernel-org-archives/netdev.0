From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 1/2] tc: flower: Introduce vlan support
Date: Mon, 22 Aug 2016 13:06:29 +0200
Message-ID: <20160822110629.GA1970@nanopsycho>
References: <1471861494-8299-1-git-send-email-hadarh@mellanox.com>
 <1471861494-8299-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36696 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbcHVLSl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:18:41 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so12922363wmf.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:18:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471861494-8299-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 22, 2016 at 12:24:53PM CEST, hadarh@mellanox.com wrote:
>Classification according to vlan id and vlan priority.
>
>Example script that adds vlan filter:
>
> # add ingress qdisc
> tc qdisc add dev ens4f0 ingress
>
> # add a flower filter with vlan id and priority classification
> tc filter add dev ens4f0 protocol 802.1Q parent ffff: \
>	flower \
>		indev ens4f0 \
>		vlan_ethtype ipv4 \
>		vlan_id 100 \
>		vlan_prio 3 \
>	action vlan pop
>
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>

Would be nice to see vlan proto support in near future.
