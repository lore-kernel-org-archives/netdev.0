From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 2 Nov 2015 13:16:17 -0800
Message-ID: <CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
	<CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
	<5637C8DF.800@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34011 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722AbbKBVQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 16:16:18 -0500
In-Reply-To: <5637C8DF.800@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 2, 2015 at 12:34 PM, Andy Lutomirski <luto@kernel.org> wrote:
> On 10/28/2015 02:39 AM, Linus Torvalds wrote:
>>
>> I'm sorry, but we don't add idiotic new interfaces like this for
>> idiotic new code like that.
>
>
> As one of the people who encouraged gcc to add this interface, I'll speak up
> in its favor:
>
> Getting overflow checking right in more complicated cases is a PITA.

No it is not. Not for unsigned values.

Stop this idiocy. Yes, overflow for signed integers can be complex.
But not for unsigned ones.

And that disgusting "overflow_usub()" in no way makes the code more
readable. EVER.

So stop just making things up. A helper function *could* have been
more legible and more efficient, if it had been about something
completely different.

But in this case it really wasn't. It wasn't more efficient, it wasn't
more legible, and it simply had no excuse for it. Stop making excuses
for shit.

                 Linus
