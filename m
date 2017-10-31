From: Jason Wang <jasowang@redhat.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Tue, 31 Oct 2017 15:00:56 +0800
Message-ID: <cd0e04bd-1fe2-c0b6-bf49-25e7e5151613@redhat.com>
References: <129a01d9-de9b-f3f1-935c-128e73153df6@linux.vnet.ibm.com>
 <3f824b0e-65f9-c69c-5421-2c5f6b349b09@redhat.com>
 <78678f33-c9ba-bf85-7778-b2d0676b78dd@linux.vnet.ibm.com>
 <038445a6-9dd5-30c2-aac0-ab5efbfa7024@linux.vnet.ibm.com>
 <20171012183132.qrbgnmvki6lpgt4a@Wei-Dev>
 <c0b42b27-56f6-c2f9-9476-28d25678808a@linux.vnet.ibm.com>
 <376f8939-1990-abf6-1f5f-57b3822f94fe@redhat.com>
 <c117c0c5-7fc0-013b-6f54-2e722d115101@linux.vnet.ibm.com>
 <20171026094415.uyogf2iw7yoavnoc@Wei-Dev>
 <da80025f-6942-615f-570e-5005a25eb147@linux.vnet.ibm.com>
 <20171031070717.wcbgrp6thrjmtrh3@Wei-Dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, netdev@vger.kernel.org, davem@davemloft.net
To: Wei Xu <wexu@redhat.com>,
        Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49150 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751539AbdJaHBN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 03:01:13 -0400
In-Reply-To: <20171031070717.wcbgrp6thrjmtrh3@Wei-Dev>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年10月31日 15:07, Wei Xu wrote:
>>> BTW, did you see any improvement when running pktgen from the host if no
>>> regression was found? Since this can be reproduced with only 1 vcpu for
>>> guest, may you try this bind? This might help simplify the problem.
>>>    vcpu0  -> cpu2
>>>    vhost  -> cpu3
>>>    pktgen -> cpu1
>>>
>> Yes -- I ran the pktgen test from host to guest with the binding
>> described.  I see an approx 5% increase in throughput from 4.12->4.13.
>> Some numbers:
>>
>> host-4.12: 1384486.2pps 663.8MB/sec
>> host-4.13: 1434598.6pps 688.2MB/sec
> That's great, at least we are aligned in this case.
>
> Jason, any thoughts on this?
>
> Wei
>

Good news is that pps is increased. I think the first step is moving 
things a little bit ahead by reposting the optimization of tx polling.

I will post a new version soon.

Thanks
