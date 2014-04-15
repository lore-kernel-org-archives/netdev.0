From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH] filter: added BPF random opcode
Date: Tue, 15 Apr 2014 11:19:21 -0700
Message-ID: <CA+ZOOTOe7c=0pYow8PZ-tKK0NPSpNKqjGF2YwGPbptE5r5PqMg@mail.gmail.com>
References: <1397516569-31033-1-git-send-email-chema@google.com>
	<534CDE99.6090407@redhat.com>
	<CA+ZOOTMmRiACgBtMSWm-Barr_MZS446Z5M2Z6B+HmZYwqcvh6A@mail.gmail.com>
	<534D61ED.9070203@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	ast@plumgrid.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:43497 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769AbaDOSTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 14:19:22 -0400
Received: by mail-oa0-f49.google.com with SMTP id o6so11178466oag.22
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 11:19:22 -0700 (PDT)
In-Reply-To: <534D61ED.9070203@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2014 at 9:44 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>>> I think using just "rnd" is cleaner here.
>>
>> I think using always random (in fact I may s/K_RAND/K_RANDOM/g) allows
>> easier grepping.
>
>
> I know it's just nitpicking, but I'd be happier if that would
> either be rnd or rand in bpf_asm.
"rand" it is.

>>> This example should rather go into Documentation/networking/filter.txt's
>>> example section, rather than tools/net/ .
>>
>> I'll add it there.
>
>
> Ok, thanks.
Done.

> For 'playing', I'd rather be happy to add that to the documentation file
> in Documentation/networking/filter.txt where we have other examples, or
> alternatively, if there is really no other way around, a new folder inside
> of Documentation/networking/ .
I think it would be better close to the tools/net/bpf* tools. Anyway,
I removed it for now.

-Chema
