From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 2 Nov 2015 15:21:48 -0800
Message-ID: <CA+55aFybA=MxezoSCN8ZtbyKdUzto3u+gOJw04w5tWQbYD-1KA@mail.gmail.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
	<CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
	<5637C8DF.800@kernel.org>
	<CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
	<CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
	<CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
	<1446502448.296003.427190649.434774F6@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446502448.296003.427190649.434774F6@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 2, 2015 at 2:14 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> overflow_usub was part of a larger header I already prepared to offer
> support for *all* overflow_* checking builtins. While fixing this IPv6
> bug I thought I could hopefully introduce this interface slowly and
> simply cut away the other versions.

Hell no.

Both you and Andy seem to argue that "since there are other totally
unrelated functions that look superficially similar and actually some
sense, we should add these stupid crap functions too".

In exactly *WHAT* crazy universe does that make sense as an argument?

It's like saying "I put literal shit on your plate, because there are
potentially nutritious sausages that look superficially a bit like the
dogshit I served you".

Seriously.

The fact that _valid_ overflow checking functions exist in _no_ way
support the crap that I got.

It's *exactly* the same argument as "dog poop superficially looks like
good sausages".

Is that really your argument?

There is never an excuse for "usub_overflow()". It's that simple.

No amount of _other_ overflow functions make that shit palatable.

                   Linus
