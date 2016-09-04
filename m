From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V5 4/4] net/sched: Introduce act_tunnel_key
Date: Sun, 4 Sep 2016 14:21:05 +0300
Message-ID: <20160904142105.5cedc050@pixies>
References: <1472986555-14949-1-git-send-email-hadarh@mellanox.com>
        <1472986555-14949-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35030 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752758AbcIDLVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 07:21:03 -0400
Received: by mail-wm0-f65.google.com with SMTP id c133so9123441wmd.2
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2016 04:21:02 -0700 (PDT)
In-Reply-To: <1472986555-14949-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  4 Sep 2016 13:55:55 +0300, hadarh@mellanox.com wrote:
> From: Amir Vadai <amir@vadai.me>
> 
> This action could be used before redirecting packets to a shared tunnel
> device, or when redirecting packets arriving from a such a device.
> 
> The action will release the metadata created by the tunnel device
> (decap), or set the metadata with the specified values for encap
> operation.
> 
> For example, the following flower filter will forward all ICMP packets
> destined to 11.11.11.2 through the shared vxlan device 'vxlan0'. Before
> redirecting, a metadata for the vxlan tunnel is created using the
> tunnel_key action and it's arguments:
> 
> $ filter add dev net0 protocol ip parent ffff: \
>     flower \
>       ip_proto 1 \
>       dst_ip 11.11.11.2 \
>     action tunnel_key set \
>       src_ip 11.11.0.1 \
>       dst_ip 11.11.0.2 \
>       id 11 \
>     action mirred egress redirect dev vxlan0
> 
> Signed-off-by: Amir Vadai <amir@vadai.me>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Thanks!
