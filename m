From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 2/2] TCPCT API sockopt update to draft -03
Date: Thu, 13 Jan 2011 19:00:18 +0100
Message-ID: <1294941618.3570.418.camel@edumazet-laptop>
References: <4D2DE824.10205@gmail.com>	<4D2DEC0A.70608@gmail.com>
	 <20110112105608.793787b2@s6510>  <4D2F3723.9040405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D2F3723.9040405@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 13 janvier 2011 =C3=A0 12:32 -0500, William Allen Simpson a =C3=
=A9crit :
> On 1/12/11 1:56 PM, Stephen Hemminger wrote:
> > On Wed, 12 Jan 2011 12:59:38 -0500
> > William Allen Simpson<william.allen.simpson@gmail.com>  wrote:
> >
> >> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> >> index e64f4c6..c8f4017 100644
> >> --- a/include/linux/tcp.h
> >> +++ b/include/linux/tcp.h
> >> @@ -185,22 +185,37 @@ struct tcp_md5sig {
> >>   #define TCP_COOKIE_PAIR_SIZE	(2*TCP_COOKIE_MAX)
> >>
> >>   /* Flags for both getsockopt and setsockopt */
> >> -#define TCP_COOKIE_IN_ALWAYS	(1<<  0)	/* Discard SYN without cook=
ie */
> >> -#define TCP_COOKIE_OUT_NEVER	(1<<  1)	/* Prohibit outgoing cookie=
s,
> >> +#define TCPCT_IN_ALWAYS		(1<<  0)	/* Discard SYN without cookie *=
/
> >> +#define TCPCT_OUT_NEVER		(1<<  1)	/* Prohibit outgoing cookies,
> >
> > You end up changing values in kernel userspace API in a way
> > that is incompatible with older applications. This is not acceptabl=
e.
> >
> While I agree in principle and argued strongly against it, other
> members of the research group (particularly the original project
> sponsor) have over-ridden my concerns.  I'm sorry to inform you that
> many/most participants don't care much about Linux.
>=20

How leaving TCP_COOKIE_IN_ALWAYS and TCP_COOKIE_OUT_NEVER definitions s=
o
that user space programs compiles can be a problem to "research group" =
?

AFAIK, TCPCT_IN_ALWAYS / TCPCT_OUT_NEVER are not mentioned in
http://www.rfc-editor.org/authors/rfc6013.txt

But TCP_COOKIE_IN_ALWAYS and TCP_COOKIE_OUT_NEVER are ...

Isnt it a bit confusing ?

> Note that the *bits* are the same, and previously compiled programs
> (that don't access more advanced features) should continue to run as
> they have in the past.
>=20
> Even though I'm not paid to work on Linux, I'm doing my best to give =
you
> folks a quick heads up and provide code to rectify the very recent ch=
anges
> that can be propagated back through the stable tree (to 2.6.33).
>=20
> As always, what you actually do with my code is up to you....

Maybe its too early, and we should wait for an official RFC, especially
if you insist breaking API in 6 months.
