From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [3.8-rc1] Networking problems after pulling-in net.git#master
Date: Sun, 23 Dec 2012 13:40:55 +0100
Message-ID: <CA+icZUU2OdNq5WKd7abNNe2eevxZBbMRS0eBGyU_rzjVBAgcOg@mail.gmail.com>
References: <CA+icZUXJeWNceo_y-TSUVzXmjbrauWmCdkgW3EJtr_vpbcrk-A@mail.gmail.com>
	<20121223114213.GB8386@liondog.tnic>
	<CA+icZUXeddp5UZ10ZWTsWLnmegHGJ+VHnr4=oAm34hXgHD2FDg@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Borislav Petkov <bp@alien8.de>,
	Sedat Dilek <sedat.dilek@gmail.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:51232 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab2LWMk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 07:40:56 -0500
In-Reply-To: <CA+icZUXeddp5UZ10ZWTsWLnmegHGJ+VHnr4=oAm34hXgHD2FDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 23, 2012 at 1:26 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Sun, Dec 23, 2012 at 12:42 PM, Borislav Petkov <bp@alien8.de> wrote:
>> On Sun, Dec 23, 2012 at 04:14:39AM +0100, Sedat Dilek wrote:
>>> Hi,
>>>
>>> after reading the thread "Regression in 3.8-rc1: "BUG: sleeping
>>> function called from invalid context"" [1] I decided to pull-in
>>> net.git#master (up to commit 9b1536c490d5: "bridge: call
>>> br_netpoll_disable in br_add_if") on top of Linus upstream.
>>>
>>> With this kernel I can't neither ping my router nor does DNS work.
>>> IIRC there were 6 commits, not sure which of them is culprit.
>>>
>>> I tried the v3.8-rc1-raring from [2] which works nicely here on
>>> Ubuntu/precise AMD64.
>>> Can't say if NetworkManager is involved or not.
>>
>> Does that mean that with Linus upstream, i.e. 3.8-rc1, you can ping your
>> router, etc?
>>
>> If so, you could bisect the 6 commits...
>>
>
> Nah, he said that b-word :-).
> The machine I am working on has some hardware damage (keyboard gets
> not detected on bios start or even within daily-work, recently I could
> not type further while writing an email, so raping that machine is not
> a good idea. I could bisect within a reduced localmodconfig setup. No
> big promises...)
>

Starting bisect session with a "localmodconfig" setup... (bad: last
commit and good: v3.8-rc1)...

- Sedat -

[1] http://www.h-online.com/open/features/Good-and-quick-kernel-configuration-creation-1403046.html
[2] http://www.kernel.org/pub/software/scm/git/docs/git-bisect.html

> - Sedat -
>
>> Thanks.
>>
>> --
>> Regards/Gruss,
>>     Boris.
>>
>> Sent from a fat crate under my desk. Formatting is fine.
>> --
