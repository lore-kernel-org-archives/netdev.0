From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V3 2/4] net/dst: Utility functions to build
 dst_metadata without supplying an skb
Date: Fri, 26 Aug 2016 09:14:40 +0300
Message-ID: <CAJ3xEMhF=xskN6bpfP2=euKiCUz=vGF_JvMsY78=kXvhQ7HY-g@mail.gmail.com>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
 <1472141627-27339-3-git-send-email-hadarh@mellanox.com> <20160825194050.262ddb5f@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:32873 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751569AbcHZGOn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 02:14:43 -0400
Received: by mail-oi0-f66.google.com with SMTP id s207so6211272oie.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 23:14:41 -0700 (PDT)
In-Reply-To: <20160825194050.262ddb5f@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 7:40 PM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> Hi,
>
> On Thu, 25 Aug 2016 19:13:45 +0300 Hadar Hen Zion <hadarh@mellanox.com> wrote:
>> From: Amir Vadai <amir@vadai.me>
>>
>> Extract _ip_tun_rx_dst() and _ipv6_tun_rx_dst() out of ip_tun_rx_dst()
>> and ipv6_tun_rx_dst(), to be used without supplying an skb.
>
> Per this v3, the newly introduced helpers ate named _ip_tun_set_dst and
> _ipv6_tun_set_dst - better alter the log message to reflect that.

sure, will fix that

>> +static inline struct metadata_dst *
>> +_ipv6_tun_set_dst(const struct in6_addr saddr, const struct in6_addr daddr,
>> +               __u8 tos, __u8 ttl, __be32 label, __be16 flags,
>> +               __be64 tunnel_id, int md_size)
>> +{
>
> Any reason not passing in6_addr pointers, as suggested?

guess not

> This is the common practice for ipv6 address parameters.

will do
