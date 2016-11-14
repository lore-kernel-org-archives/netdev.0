From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [LKP] [net] 2ab9fb18c4: kernel BUG at
 include/linux/skbuff.h:1935!
Date: Mon, 14 Nov 2016 11:11:30 +0800
Message-ID: <20161114031130.yjb4anou24ede4ue@wfg-t540p.sh.intel.com>
References: <5828fc09.rTUEnj6qw0eDHzYL%xiaolong.ye@intel.com>
 <1479088020.8455.41.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161114021420.GC31218@yexl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Jojy Varghese <jojvargh@cisco.com>,
        Tom Herbert <tom@herbertland.com>,
        Yibin Yang <yibyang@cisco.com>, lkp@01.org,
        David Miller <davem@davemloft.net>
To: Ye Xiaolong <xiaolong.ye@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:52511 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932373AbcKNDLe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 22:11:34 -0500
Content-Disposition: inline
In-Reply-To: <20161114021420.GC31218@yexl-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>Hi guys.
>>
>>I took a look at the commit again and I do not see how this can happen.
>>
>>Are you sure patch was properly applied ?
>>
>>In particular, the following extract is obscure for me :
>>
>>
>>> https://github.com/0day-ci/linux Eric-Dumazet/net-__skb_flow_dissect-must-cap-its-return-value/20161110-080839
>>> commit 2ab9fb18c46b91b16a0f0f329336d3be9fc32deb ("net: __skb_flow_dissect() must cap its return value")
>>>
>
>Hi,
>
>The above two lines means 0day repo setup a new branch
>"Eric-Dumazet/net-__skb_flow_dissect-must-cap-its-return-value/20161110-080839"
>which is based on net/master, then applied you patch on top of it,
>commit id is 2ab9fb18c46b91b16a0f0f329336d3be9fc32deb.

Xiaolong, it may be more helpful to show the base tree where we apply
the patch to. And the final url:

https://github.com/0day-ci/linux/tree/Eric-Dumazet/net-__skb_flow_dissect-must-cap-its-return-value/20161110-080839

Thanks,
Fengguang
