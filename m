From: =?UTF-8?Q?Michal_Seklet=C3=A1r?= <sekletar.m@gmail.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Mon, 9 Dec 2013 15:09:23 +0100
Message-ID: <CAJ7VeQz67Q2HSMd-AP7MApaFWe8z6bERFGzH-PqLak1KK77sGA@mail.gmail.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7466@saturn3.aculab.com>
	<52A1A099.3010901@redhat.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7469@saturn3.aculab.com>
	<20131206.121523.75881126286614298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David.Laight@aculab.com, Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:60107 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933562Ab3LIOJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 09:09:24 -0500
Received: by mail-vb0-f52.google.com with SMTP id p5so553401vbn.11
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 06:09:23 -0800 (PST)
In-Reply-To: <20131206.121523.75881126286614298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure I follow. Not going to accommodate, meaning at all or you
just my original approach? If later applies, I'll be happy to rewrite
the patch.

On Fri, Dec 6, 2013 at 6:15 PM, David Miller <davem@davemloft.net> wrote:
> From: "David Laight" <David.Laight@ACULAB.COM>
> Date: Fri, 6 Dec 2013 11:15:58 -0000
>
>>>   i) Does BSD have such extensions and if so do we overlap some?
>>>
>>> ii) Is it planned to also introduce SO_BPF_EXTENSIONS for BSD kernels
>>>      to have one common api (that i.e. libpcap would then make use of)?
>>
>> If it is useful to add any of the extensions, and they don't collide
>> with any other existing changes, then they might be added.
>> Adding a request that indicates which extensions are supported should
>> be easier than adding the extensions themselves.
>> Adding all the Linux extensions at once could be problematic.
>
> Again, we're not going to accomodate this, sorry.
