From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP IP Offloading Interface
Date: Mon, 14 Jul 2003 22:51:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030714225133.18395b69.davem@redhat.com>
References: <E3738FB497C72449B0A81AEABE6E713C027A43@STXCHG1.simpletech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   netdev@oss.sgi.com, alan@storlinksemi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jordi Ros" <jros@xiran.com>
In-Reply-To: <E3738FB497C72449B0A81AEABE6E713C027A43@STXCHG1.simpletech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Jul 2003 22:42:55 -0700
"Jordi Ros" <jros@xiran.com> wrote:

[ Please fix Outlook Express or whatever lame email client you
  use to put newlines into the emails that you compose.  These
  excessive long lines make your emails nearly impossible to read ]

> TCP offloading does not necessarily need to be the goal but a MUST
> if one wants to build a performance-scalable architecture. This
> vision is in fact introduced by Mogul in his paper. He writes:
> "Therefore, offloading the transport layer becomes valuable not for
> its own sake, but rather because that allows offloading of the RDMA
> [...]".

I totally disagree.  It is not a MUST, in fact I have described
an alternative implementation that requires none of the complexity
or RDMA, and none of the stupidity of TOE.

Read my lips: "We do not need to offload TCP itself to get the
attributes you desire, therefore we are NOT going to do it."

You can choose to ignore my suggestions and likewise I will continue
to ignore the endless (and frankly, broing after reading it for the
100th time) spouting from people like you that we somehow "NEED" or
"MUST" have TOE, which is complete bullshit as exemplified by my
alternative example scheme.

You also ignore the points others have made that the systems HAVE
SCALED to evolving networks technologies as they have become faster
and faster.

And when you ignore me, don't be surprised when other companies come
along, implement my scheme, it gets supported in Linux and
subsequently the stock of your company effectively becomes toilet
paper and TOE is an obscure piece of computing history gone wrong :-)

> TOE is believed to not provide performance. I may agree that TOE by
> itself may not, but TOE as a means to deliver some other technology
> (e.g. RDMA, encryption or Direct Path) it does optimize (in some
> instance dramatically) the overall performance. Let me show you the
> numbers in our Direct Path technology. 

But our point is that you don't need any of this crap.

My RX receive page accumulation scheme handles all of the
receive side problems with touching the data and getting
into the filesystem and then the device.  With my scheme
you can receive the data, go direct to the device, and the
cpu never touches one byte.

> Note that Microsoft is considering TOE under its Scalable Networking
> Program. To keep linux competitive, I would encourage a healthy
> discussion on this matter

I actually welcome Microsoft falling into this rathole of a
technology.  Let them have to support that crap and have to field bug
reports on it, having to wonder who created the packets.  And let them
deal with the negative effects TOE has on connection rates and things
like that.

Linux will be competitive, especially if people develop the scheme I
have described several times into the hardware.  There are vendors
doing this, will you choose to be different and ignore this?
