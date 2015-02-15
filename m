From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH net-next 1/6] ppc: Kconfig: Enable BPF JIT on ppc32
Date: Sun, 15 Feb 2015 23:16:31 +0400
Message-ID: <CAOJe8K2V3Wde6dLE3QyBZKK7YSEpzBXZi+5VSCJsr5QiYNOQCg@mail.gmail.com>
References: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
	<1424023605-2416-2-git-send-email-kda@linux-powerpc.org>
	<1424024154.2685.1.camel@perches.com>
	<20150215.110729.1985006476906451021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: joe@perches.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:52344 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754194AbbBOTQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 14:16:32 -0500
Received: by mail-yh0-f44.google.com with SMTP id f73so12366874yha.3
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 11:16:31 -0800 (PST)
In-Reply-To: <20150215.110729.1985006476906451021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/15/15, David Miller <davem@davemloft.net> wrote:
> From: Joe Perches <joe@perches.com>
> Date: Sun, 15 Feb 2015 10:15:54 -0800
>
>> On Sun, 2015-02-15 at 21:06 +0300, Denis Kirjanov wrote:
>> []
>>> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
>> []
>>> @@ -126,7 +126,7 @@ config PPC
>>>  	select IRQ_FORCED_THREADING
>>>  	select HAVE_RCU_TABLE_FREE if SMP
>>>  	select HAVE_SYSCALL_TRACEPOINTS
>>> -	select HAVE_BPF_JIT if PPC64
>>> +	select HAVE_BPF_JIT
>>
>> trivia:
>>
>> Should this be the last patch of the series?
>
> Yes, that's the way I see it too.
>

Ok, I'll resend the series if the such thing matters.

Thank you.
