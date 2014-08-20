From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity protection
Date: Wed, 20 Aug 2014 10:24:46 +0200
Message-ID: <CAPh34mckmKkRqG7M=37hHRJjBzZ+43BaPnjvpC5sEFnpPqj0aA@mail.gmail.com>
References: <52A75EF8.3010308@in.tum.de>
	<20131211.150137.368953964178408437.davem@davemloft.net>
	<52A8C8B4.4060109@in.tum.de>
	<20131211122637.75b09074@nehalam.linuxnetplumber.net>
	<87bo0nulkt.fsf@tassilo.jf.intel.com>
	<52A8ECF5.3070604@in.tum.de>
	<20131212012317.GL21717@two.firstfloor.org>
	<52A98DBF.4090702@appelbaum.net>
	<52A9A17F.6050505@in.tum.de>
	<1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<53F3A739.4070203@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christian Grothoff <grothoff@in.tum.de>,
	Jacob Appelbaum <jacob@appelbaum.net>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	knock@gnunet.org
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53F3A739.4070203@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19 August 2014 21:36, Alexander Holler <holler@ahsoftware.de> wrote:

> It doesn't have to work in every environment and it doesn't have to solve
> all existing problems in the world. ;)
>
> But it enables people to protect a bit more against malicious people or
> governments.
>
> And it is really very easy to use. It took me around half an hour to find
> the places in openvpn and openssh where I had to add the setsockopt() call
> and it can be used even easier with preloading libknockify.so.
>
> There can be found much more useless options in the kernel. At least I like
> it and it fits my needs too.

It's not about to add another "useless options", it's about changing
the major transport protocol. You should probably join the IETF
tcpm/tcpinc mailing list where TCP stealth is currently actively
discussed. TCP stealth has problems and you can probably help to
address them on a *technical level* if you like the mechanism.

Hagen
