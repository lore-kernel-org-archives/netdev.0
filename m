From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and coding-style
Date: Mon, 10 Jan 2011 14:12:46 +0200
Message-ID: <AANLkTim0U22b+S=9qZj5BP5TTxEM=U2BhpO4ZjfQAuOz@mail.gmail.com>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be>
	<1294614389.2823.35.camel@localhost>
	<AANLkTik7mug7j=VLz80DX_hJokeO3=ie+KRcMViSL4kB@mail.gmail.com>
	<201101101244.24932.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Randy Dunlap <rdunlap@xenotime.net>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39455 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883Ab1AJMMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 07:12:47 -0500
In-Reply-To: <201101101244.24932.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/1/10 Christoph Paasch <christoph.paasch@uclouvain.be>:
>
> On Monday, January 10, 2011 wrote Alexey Dobriyan:
>> >> linux/percpu_counter.h (needed for percpu_counter_sum_positive)
>> >
>> > Yes.
>>
>> Currently code compiles fine, so necessary headers are in place,
>> so simply adding new headers doesn't help anything.
>
> I totally agree with you.
> However we need a consistent coding style.
>
> Or we just include the minimum necessary headers (as originally proposed by
> me).
> Or we include every header whose structs/functions are referenced.

This is false dichotomy and extreme siding.

We need code that compiles.
We need headers to include realistically minimum amount of stuff (not
#include lines,
but stuff)

> In my opinion the current "mixed" state is not ok, because some includes are
> there because there *are* references (even if these includes could be omitted,
> e.g., linux/list.h).
> Other includes (like linux/percpu_counter.h) are not there, because they are
> indirectly included by another header and thus the code compiles. Even if
> there are references.
> And there are no rules/guidelines to identify the headers that should be
> included and those that should not.

That because the issue not that important. :-)
