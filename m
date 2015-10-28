From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [GIT] Networking
Date: Wed, 28 Oct 2015 15:27:41 +0100
Message-ID: <87pozzvzj6.fsf@rasmusvillemoes.dk>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
	<CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
	<1446030209.105419.422375497.14563933@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446030209.105419.422375497.14563933@webmail.messagingengine.com>
	(Hannes Frederic Sowa's message of "Wed, 28 Oct 2015 12:03:29 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28 2015, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> Hi Linus,
>
> On Wed, Oct 28, 2015, at 10:39, Linus Torvalds wrote:
>> Get rid of it. And I don't *ever* want to see that shit again.
>
> I don't want to give up on that this easily:
>
> In future I would like to see an interface like this. It is often hard
> to do correct overflow/wrap-around tests and it would be great if there
> are helper functions which could easily and without a lot of thinking be
> used by people to remove those problems from the kernel.

I agree - proper overflow checking can be really hard. Quick, assuming a
and b have the same unsigned integer type, is 'a+b<a' sufficient to
check overflow? Of course not (hint: promotion rules). And as you say,
it gets even more complicated for signed types.

A few months ago I tried posting a complete set of fallbacks for older
compilers (https://lkml.org/lkml/2015/7/19/358), but nothing really
happened. Now I know where Linus stands, so I guess I can just delete
that branch.

Rasmus
