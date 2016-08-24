From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V2 2/4] net/dst: Utility functions to build
 dst_metadata without supplying an skb
Date: Wed, 24 Aug 2016 21:26:48 +0300
Message-ID: <20160824212648.43c45295@halley>
References: <20160824122710.30356-1-amir@vadai.me>
        <20160824122710.30356-3-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34201 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753113AbcHXT2s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 15:28:48 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so4044390wma.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 12:27:53 -0700 (PDT)
In-Reply-To: <20160824122710.30356-3-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 24 Aug 2016 15:27:08 +0300 Amir Vadai <amir@vadai.me> wrote:
> +static inline struct metadata_dst *
> +_ipv6_tun_rx_dst(struct in6_addr saddr, struct in6_addr daddr,
> +		 __u8 tos, __u8 ttl, __be32 label,
> +		 __be16 flags, __be64 tunnel_id, int md_size)
> +{

Prefer 'const struct in6_addr *saddr' parameter (daddr too).

This is aligned with almost all functions having an 'in6_addr' as a
parameter, to prevent the costy argument copy.
