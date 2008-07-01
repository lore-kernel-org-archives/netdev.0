From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: kmemcheck detected possible information leak to userspace?
Date: Tue, 1 Jul 2008 14:17:48 +0200
Message-ID: <19f34abd0807010517w6e2003d6j86922df0aa0052ac@mail.gmail.com>
References: <19f34abd0807010216k11a60382xf7a27b4b27f0819@mail.gmail.com>
	 <20080701102459.GB30248@2ka.mipt.ru>
	 <19f34abd0807010352t264fda16g826912a857e88140@mail.gmail.com>
	 <87skutu8pw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:60235 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756772AbYGAMRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 08:17:49 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1982461wfd.4
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2008 05:17:48 -0700 (PDT)
In-Reply-To: <87skutu8pw.fsf@basil.nowhere.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 1, 2008 at 1:47 PM, Andi Kleen <andi@firstfloor.org> wrote:
> "Vegard Nossum" <vegard.nossum@gmail.com> writes:
>
>> But there is one thing I forgot: Is this memory initialized by DMA? If
>> so, the warning is bogus and I will go hide in shame.
>
> Yes it is.
>
> [btw that was something I noted during the initial review and was then
> ridiculed for]

I just went back and reviewed the original thread. (I assume you're
talking about the kmemcheck v3 thread,
http://lkml.org/lkml/2008/2/7/500.)

I'm sorry about having forgotten this particular comment you made.
Please take into account that before December last year, I didn't even
know what an skbuff was. And I didn't know how DMA worked. There can
be a lot of things that slip past when I don't have the basic mental
hooks on which to hang them. (Though, I must say, those discussions
have taught me a lot.) There was also the fact that Ingo for a long
time carried patches to silence these warnings, but which were dropped
before the 2.6.26 merge window because they should go through the
right maintainers instead of the x86 tree. I forgot about it, so I've
made a mistake this time.

But I don't see that you were ever ridiculed. In fact, I am only
grateful for all the comments you've made, and the help you've been.


Vegard

PS: The error I just reported was different from the ones we've had
before, which is why I didn't recognize it immediately.

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
