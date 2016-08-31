From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V4 4/4] net/sched: Introduce act_tunnel_key
Date: Wed, 31 Aug 2016 17:39:33 +0200
Message-ID: <20160831153933.GD1986@nanopsycho>
References: <1472647584-6713-1-git-send-email-hadarh@mellanox.com>
 <1472647584-6713-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36200 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934320AbcHaPjh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 11:39:37 -0400
Received: by mail-wm0-f66.google.com with SMTP id i138so8158661wmf.3
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 08:39:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472647584-6713-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 31, 2016 at 02:46:24PM CEST, hadarh@mellanox.com wrote:
>From: Amir Vadai <amir@vadai.me>
>
>This action could be used before redirecting packets to a shared tunnel
>device, or when redirecting packets arriving from a such a device.
>
>The action will release the metadata created by the tunnel device
>(decap), or set the metadata with the specified values for encap
>operation.
>
>For example, the following flower filter will forward all ICMP packets
>destined to 11.11.11.2 through the shared vxlan device 'vxlan0'. Before
>redirecting, a metadata for the vxlan tunnel is created using the
>tunnel_key action and it's arguments:
>
>$ filter add dev net0 protocol ip parent ffff: \
>    flower \
>      ip_proto 1 \
>      dst_ip 11.11.11.2 \
>    action tunnel_key set \
>      src_ip 11.11.0.1 \
>      dst_ip 11.11.0.2 \
>      id 11 \
>    action mirred egress redirect dev vxlan0
>
>Signed-off-by: Amir Vadai <amir@vadai.me>
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>


Looks fine to me
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
