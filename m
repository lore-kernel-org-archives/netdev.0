From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH net-next V5 4/4] net/sched: Introduce act_tunnel_key
Date: Sun, 4 Sep 2016 18:19:24 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F92CE10540@HASMSX110.ger.corp.intel.com>
References: <1472986555-14949-1-git-send-email-hadarh@mellanox.com>
 <1472986555-14949-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:36339 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753581AbcIDST2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Sep 2016 14:19:28 -0400
In-Reply-To: <1472986555-14949-5-git-send-email-hadarh@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Hadar,

>For example, the following flower filter will forward all ICMP packets destined to 11.11.11.2 >through the shared vxlan device 'vxlan0'. Before redirecting, a metadata for the vxlan tunnel >is created using the tunnel_key action and it's arguments:

Shouldn't it be "tc filter add dev ..."?

>$ filter add dev net0 protocol ip parent ffff: \
>    flower \
>      ip_proto 1 \
>      dst_ip 11.11.11.2 \
>    action tunnel_key set \
>      src_ip 11.11.0.1 \
>      dst_ip 11.11.0.2 \
>      id 11 \
>    action mirred egress redirect dev vxlan0

Regards,
Rami Rosen
Intel Corporation
