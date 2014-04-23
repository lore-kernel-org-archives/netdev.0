From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 19:10:49 +0200
Message-ID: <5357F419.1020909@redhat.com>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com> <20140422.235745.1219194947074686642.davem@davemloft.net> <1398229980.29914.6.camel@edumazet-glaptop2.roam.corp.google.com> <20140423.125126.244770898759207308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55793 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751532AbaDWRK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 13:10:59 -0400
In-Reply-To: <20140423.125126.244770898759207308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2014 06:51 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 22 Apr 2014 22:13:00 -0700
>
>> On Tue, 2014-04-22 at 23:57 -0400, David Miller wrote:
>>> From: Alexei Starovoitov <ast@plumgrid.com>
>>> Date: Tue, 22 Apr 2014 20:18:57 -0700
>>>
>>>> exisiting BPF verifier allows uninitialized access to registers,
>>>> 'ret A' is considered to be a valid filter.
>>>> So initialize A and X to zero to prevent leaking kernel memory
>>>> In the future BPF verifier will be rejecting such filters
>>>>
>>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>>
>>> Has the code always been like this?
>>>
>>> Did the eBPF changes introduce this problem either directly or
>>> indirectly?
>>
>> Original code was fine AFAIK
>>
>> Fixes: bd4cf0ed331a2 ("net: filter: rework/optimize internal BPF interpreter's instruction set")
>>
>> David, is it possible for you to push net-next tree ?
>
> What exactly are you asking me to do?  Put this patch in the net-next tree?
> Or are you asking me to merge net into net-next after I apply it?
>
> It's definitely a 'net' patch.

I think Eric already clarified it in [1].

It's definitely against net tree.

 From my side, it would be awesome, if you could put this into net and
then merge net into net-next as I have some pending stuff on top of
this fix. That would at least avoid a bigger merge conflict later on.

Thanks a lot, Dave.

  [1] http://patchwork.ozlabs.org/patch/341693/, April 23, 2014, 1:39 p.m.
