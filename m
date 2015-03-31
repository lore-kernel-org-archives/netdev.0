From: Ian Morris <ipm@chirality.org.uk>
Subject: Re: [PATCH net-next 0/2] ipv6: coding style - comparisons with NULL
Date: Tue, 31 Mar 2015 17:39:00 +0100
Message-ID: <551ACDA4.8000302@chirality.org.uk>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk> <1427650577.2715.32.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:45461 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754141AbbCaQjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 12:39:04 -0400
In-Reply-To: <1427650577.2715.32.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Joe,

Many thanks for your invaluable feedback, as ever!

I was aware this one has the potential to be a somewhat controversial 
topic and whilst my analysis was not quite as scientific as yours I too 
had detected the preference for the shorter form hence the reason for 
adopting that style : however your stats are a great illustration so 
thanks for putting them forward.

I guess the thing with coding style is precisely that : it's a style 
rather than something that is correct or not but my perspective (FWIW, 
probably not that much!) is that we should at least try to be consistent 
within an area of code. As such I can totally understand one area using 
NULL and another not given the size of the kernel as a whole but I 
thought it worth trying to align stuff within IPV6.

IPV6 is a particular interest for me but I'd be happy to cook up a 
similar patch for IPV4 if there's interest.

Thanks again,

Ian.

On 29/03/15 18:36, Joe Perches wrote:
> On Sun, 2015-03-29 at 14:00 +0100, Ian Morris wrote:
>> The IPV6 code uses multiple different styles when comparing with NULL
>> (I.e. x == NULL and !x as well as x != NULL and x). Generally the
>> latter form is preferred according to checkpatch and so this changes
>> aligns the code to this style.
> Hello Ian.
>
> While I prefer this style, it can be a "maintainer's choice"
> preference and this might be a bit contentious to some.
>
> It might be nice to show the relative counts of each form
> before this change to show the relative counts use of each
> form to help establish consensus for the value for this patch.
>
> (Or David could just apply it instead:)
>
> Using coccinelle to check for pointer comparisons with and
> without NULL for net/ipv6/*.[ch]:
>
> with NULL:	260
> without NULL:	779
>
> So there was a 3:1 preference for the bare form.
>
> (and for net/ipv4/*.[ch] it's closer to 4:1)
>
> with NULL:	276
> without NULL:	914
>
> (trivial cocci script below)
> @@
> type A;
> A *b;
> @@
>
> * b == NULL
>
> @@
> type A;
> A *b;
> @@
>
> * b != NULL
>
>
>
