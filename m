From: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Wed, 14 Jan 2009 14:59:54 +0530
Message-ID: <3f9a31f40901140129i1389f47frf32808f3a695a118@mail.gmail.com>
References: <1231836016.3212.41.camel@jaswinder.satnam>
	 <Pine.LNX.4.64.0901140954250.27308@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:14415 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759546AbZANJ3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 04:29:55 -0500
In-Reply-To: <Pine.LNX.4.64.0901140954250.27308@anakin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Geert,

On Wed, Jan 14, 2009 at 2:26 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> On Tue, 13 Jan 2009, Jaswinder Singh Rajput wrote:
>> Please pull these patches. Earlier I also floated these patches so that I can get some feedback.
>>
>> The following changes since commit ae2659bcd0b5bf34dd4b03f1db0a2942cc09b8e6:
>>   Ingo Molnar (1):
>>         Merge branch 'x86/mm'
>>
>> are available in the git repository at:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/linux-2.6-tiptop.git master
>>
>> Jaswinder Singh Rajput (7):
>>       include of <linux/types.h> is preferred over <asm/types.h>
>>       found __[us]{8,16,32,64} type without #include <linux/types.h>
>>       capability.h: extern's make no sense in userspace
>>       coda_psdev.h: extern's make no sense in userspace
>>       in6.h: extern's make no sense in userspace
>>       nubus.h: extern's make no sense in userspace
>>       socket.h: extern's make no sense in userspace
>
> May I please remind you of my comment in
> http://patchwork.kernel.org/patch/2093/?
>

Thanks for your reminder :-)

> At least nubus.h still leaks forward declarations for kernel functions that
> lack the "extern" keyword, so they still pollute user space.
>

Yes, you are right, I just tried to pampered weeping warning messages
which is annoying.

In this subset, I just try to fix 77 such warnings.

nubus.h still have such warnings and other fixes required which you
are pointing so I am expecting nubus people will solve such problems.

Thanks
--
JSR
