From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH net-next 0/3] Implement delete for BPF LPM trie
Date: Tue, 19 Sep 2017 23:31:33 +0200
Message-ID: <2c5c42f5-4625-da6d-1d04-904ae6f8fb20@zonque.org>
References: <20170919.135530.717500199880384307.davem@davemloft.net>
 <94373907-6cf5-22af-54e6-7625f31447e0@zonque.org>
 <CAEfhGiybHecYsJ+3eXMFfohh_Jp_yyDfr8ZkydGaQyZJbVQXwA@mail.gmail.com>
 <20170919.142935.72220924483937276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bugwerft.de ([46.23.86.59]:51618 "EHLO mail.bugwerft.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751309AbdISVbf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 17:31:35 -0400
In-Reply-To: <20170919.142935.72220924483937276.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2017 11:29 PM, David Miller wrote:
> From: Craig Gallek <kraigatgoog@gmail.com>
> Date: Tue, 19 Sep 2017 17:16:13 -0400
> 
>> On Tue, Sep 19, 2017 at 5:13 PM, Daniel Mack <daniel@zonque.org> wrote:
>>> On 09/19/2017 10:55 PM, David Miller wrote:
>>>> From: Craig Gallek <kraigatgoog@gmail.com>
>>>> Date: Mon, 18 Sep 2017 15:30:54 -0400
>>>>
>>>>> This was previously left as a TODO.  Add the implementation and
>>>>> extend the test to cover it.
>>>>
>>>> Series applied, thanks.
>>>>
>>>
>>> Hmm, I think these patches need some more discussion regarding the IM
>>> nodes handling, see the reply I sent an hour ago. Could you wait for
>>> that before pushing your tree?
>>
>> I can follow up with a patch to implement your suggestion.  It's
>> really just an efficiency improvement, though, so I think it's ok to
>> handle independently. (Sorry, I haven't had a chance to play with the
>> implementation details yet).
> 
> Sorry, I thought the core implementation had been agreed upon and the
> series was OK.  All that was asked for were simplifications and/or
> optimization which could be done via follow-up patches.
> 
> It's already pushed out to my tree, so I would need to do a real
> revert.
> 
> I hope that won't be necessary.
> 

Nah, it's okay I guess. I trust Craig to send follow-up patches. After
all, efficiency is what this whole exercise is all about, so I think it
should be done correctly :)



Thanks,
Daniel
