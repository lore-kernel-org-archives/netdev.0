From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Fri, 06 Dec 2013 11:02:01 +0100
Message-ID: <52A1A099.3010901@redhat.com>
References: <1385639832-3938-1-git-send-email-msekleta@redhat.com> <1385659889.5352.25.camel@edumazet-glaptop2.roam.corp.google.com> <5298A0EF.70401@redhat.com> <CAJ7VeQwC7xPPujCN8kQ3KcJAhykwQXLFA=vw2gWABmpUvuz1og@mail.gmail.com> <1386264770.30495.204.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7466@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?TWljaGFsIFNla2xldMOh?= =?UTF-8?B?cg==?=
	<sekletar.m@gmail.com>, Michal Sekletar <msekleta@redhat.com>,
	netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54811 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961Ab3LFK1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 05:27:19 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7466@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 10:50 AM, David Laight wrote:
>> if SO_BPF_EXTENSIONS is supported, than you can assume that all current
>> extensions are supported.
>>
>> No need to consume one bit per feature, as all these features wont ever
>> disappear from linux.
>
> However one of the BSDs could add a subset of the features and
> wish to advertise the fact.
> So using extra flags for non-trivial extensions could be useful.

Haven't had a closer look at the BSD BPF code /yet/, so ...

  i) Does BSD have such extensions and if so do we overlap some?

ii) Is it planned to also introduce SO_BPF_EXTENSIONS for BSD kernels
     to have one common api (that i.e. libpcap would then make use of)?

> 	David
>
