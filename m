From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Fri, 06 Dec 2013 13:04:50 +0100
Message-ID: <52A1BD62.50605@redhat.com>
References: <1385639832-3938-1-git-send-email-msekleta@redhat.com> <1385659889.5352.25.camel@edumazet-glaptop2.roam.corp.google.com> <5298A0EF.70401@redhat.com> <CAJ7VeQwC7xPPujCN8kQ3KcJAhykwQXLFA=vw2gWABmpUvuz1og@mail.gmail.com> <1386264770.30495.204.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7466@saturn3.aculab.com> <52A1A099.3010901@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7469@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?TWljaGFsIFNla2xldMOh?= =?UTF-8?B?cg==?=
	<sekletar.m@gmail.com>, Michal Sekletar <msekleta@redhat.com>,
	netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757664Ab3LFMFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 07:05:16 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7469@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 12:15 PM, David Laight wrote:
>> From: Daniel Borkmann

>> Haven't had a closer look at the BSD BPF code /yet/, so ...
>
> I've not looked either.
>
>>    i) Does BSD have such extensions and if so do we overlap some?
>>
>> ii) Is it planned to also introduce SO_BPF_EXTENSIONS for BSD kernels
>>       to have one common api (that i.e. libpcap would then make use of)?
>
> If it is useful to add any of the extensions, and they don't collide
> with any other existing changes, then they might be added.
> Adding a request that indicates which extensions are supported should
> be easier than adding the extensions themselves.

Btw, we have aa1113d9f85da5 for that, but I see the point to get all
at once.

Ideally, they shouldn't even be added manually to this getsockopt,
plus we need to be careful of not preventing us in future from adding
additional extensions if they are needed for some good reason (hence,
the 1 bit, but maybe there's another better solution; haven't had
time to think about it so far).
