From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V5 4/4] net/sched: Introduce act_tunnel_key
Date: Mon, 5 Sep 2016 09:45:34 +0300
Message-ID: <CAJL1qvHyGiPOiRceD2N+SgTih0Bggr-_1_1OtzCFHW8Yu1FR0A@mail.gmail.com>
References: <1472986555-14949-1-git-send-email-hadarh@mellanox.com>
 <1472986555-14949-5-git-send-email-hadarh@mellanox.com> <9B0331B6EBBD0E4684FBFAEDA55776F92CE10540@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33341 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754010AbcIEGpg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 02:45:36 -0400
Received: by mail-oi0-f65.google.com with SMTP id w78so3846492oie.0
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2016 23:45:35 -0700 (PDT)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F92CE10540@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 4, 2016 at 9:19 PM, Rosen, Rami <rami.rosen@intel.com> wrote:
> Hi, Hadar,
>
>>For example, the following flower filter will forward all ICMP packets destined to 11.11.11.2 >through the shared vxlan device 'vxlan0'. Before redirecting, a metadata for the vxlan tunnel >is created using the tunnel_key action and it's arguments:
>
> Shouldn't it be "tc filter add dev ..."?

yes, I'll fix it to next version.

Thanks,
Hadar

>
>>$ filter add dev net0 protocol ip parent ffff: \
>>    flower \
>>      ip_proto 1 \
>>      dst_ip 11.11.11.2 \
>>    action tunnel_key set \
>>      src_ip 11.11.0.1 \
>>      dst_ip 11.11.0.2 \
>>      id 11 \
>>    action mirred egress redirect dev vxlan0
>
> Regards,
> Rami Rosen
> Intel Corporation
>
