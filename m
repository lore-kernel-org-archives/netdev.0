From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] sock: make lockdep_sock_is_held static inline
Date: Fri, 8 Apr 2016 01:13:13 +0200
Message-ID: <5706E989.4020902@stressinduktion.org>
References: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
 <1460068227.6473.422.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460068652.6473.423.camel@edumazet-glaptop3.roam.corp.google.com>
 <5706E39D.3060206@stressinduktion.org>
 <1460070528.6473.425.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36731 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756580AbcDGXNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 19:13:22 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 68058208C5
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 19:13:16 -0400 (EDT)
In-Reply-To: <1460070528.6473.425.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.04.2016 01:08, Eric Dumazet wrote:
> On Fri, 2016-04-08 at 00:47 +0200, Hannes Frederic Sowa wrote:
>
>> I see... hmpf.
>>
>> Wouldn't it be nicer if I include a helper a la:
>>
>> #define lockdep_is_held(lock)  1
>>
>> in lockdep.h in case lockdep is globally not enabled? I do actually have
>> already another user for this outside of PROVE_RCU.
>
> It probably had been discussed on lkml a long time ago.
>
> My guess is that you can not do that, but am too lazy to tell you why ;)

I will simply try it and otherwise go with your solution. My other cases 
would need to be ifdefed then as well, but also possible.

Patch is send out and I will now research after your tip that it was 
already tried.

Thanks,
Hannes
