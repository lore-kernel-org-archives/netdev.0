From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next V3 3/4] net/sched: cls_flower: Classify packet
 in ip tunnels
Date: Fri, 26 Aug 2016 12:46:56 +0200
Message-ID: <20160826124656.78c7d380@griffin>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
        <1472141627-27339-4-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58320 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751503AbcHZKrB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 06:47:01 -0400
In-Reply-To: <1472141627-27339-4-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a nit,

On Thu, 25 Aug 2016 19:13:46 +0300, Hadar Hen Zion wrote:
> $ filter add dev vxlan0 protocol ip parent ffff: \
>     flower \
>       enc_src_ip 11.11.0.2 \
>       enc_dst_ip 11.11.0.1 \
>       enc_key_id 11 \
>       dst_ip 11.11.11.1 \
>     action iptunnel decap \

             ^ this is now called tunnel_key :-)

>     action mirred egress redirect dev vnet0
> 
> The action iptunnel, will be introduced in the next patch in this

             ^ and here.

Thanks!

 Jiri
