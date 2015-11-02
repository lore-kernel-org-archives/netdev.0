From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 2 Nov 2015 13:19:23 -0800
Message-ID: <CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
	<CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
	<5637C8DF.800@kernel.org>
	<CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 2, 2015 at 1:16 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Nov 2, 2015 at 12:34 PM, Andy Lutomirski <luto@kernel.org> wrote:
>>
>> Getting overflow checking right in more complicated cases is a PITA.
>
> No it is not. Not for unsigned values.

Just to clarify. The "oevrflow" test for unsigned subtracts  of "a-b"
(it's really an underflow, but whatever) really is just

   (b > a)

Really. That's it. Claiming that that is "complicated" and needs a
helper function is not something sane people do. A fifth-grader that
isn't good at math can understand that.

In contrast, nobody sane understands "usub_overflow(a, b, &res)".

So really. Stop making inane arguments.

                  Linus
