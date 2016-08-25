From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V3 2/4] net/dst: Utility functions to build
 dst_metadata without supplying an skb
Date: Thu, 25 Aug 2016 19:40:50 +0300
Message-ID: <20160825194050.262ddb5f@halley>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
        <1472141627-27339-3-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35692 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756273AbcHYQlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:41:09 -0400
Received: by mail-wm0-f65.google.com with SMTP id i5so8148666wmg.2
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:40:58 -0700 (PDT)
In-Reply-To: <1472141627-27339-3-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 25 Aug 2016 19:13:45 +0300 Hadar Hen Zion <hadarh@mellanox.com> wrote:
> From: Amir Vadai <amir@vadai.me>
> 
> Extract _ip_tun_rx_dst() and _ipv6_tun_rx_dst() out of ip_tun_rx_dst()
> and ipv6_tun_rx_dst(), to be used without supplying an skb.

Per this v3, the newly introduced helpers ate named _ip_tun_set_dst and
_ipv6_tun_set_dst - better alter the log message to reflect that.

> +static inline struct metadata_dst *
> +_ipv6_tun_set_dst(const struct in6_addr saddr, const struct in6_addr daddr,
> +		  __u8 tos, __u8 ttl, __be32 label, __be16 flags,
> +		  __be64 tunnel_id, int md_size)
> +{

Any reason not passing in6_addr pointers, as suggested?
This is the common practice for ipv6 address parameters.

Thanks,
Shmulik
