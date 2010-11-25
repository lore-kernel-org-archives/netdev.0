From: nisse@lysator.liu.se (Niels =?iso-8859-1?Q?M=F6ller?=)
Subject: Re: TCP_MAXSEG vs TCP/generic segmentation offload (tso/gso)
Date: Thu, 25 Nov 2010 16:09:49 +0100
Message-ID: <nnaakxqw1u.fsf@stalhein.lysator.liu.se>
References: <nny68hqzzn.fsf@stalhein.lysator.liu.se>
	<1290695253.2858.336.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290695253.2858.336.camel@edumazet-laptop> (Eric Dumazet's
	message of "Thu, 25 Nov 2010 15:27:33 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> So... there is no 'bug', unless you trust too much tcpdump output.

I really expected tcpdump -e to display the actual values in the link
layer header, including the correct frame size. It's more than a bit
confusing if that is not the case...

In the future, I will try to remember to always run tcpdump on a networ=
k
node which (i) is different from the sending one, and (ii) has GRO
disabled (and hence will discard packets if it has trouble processing
them all, rather than coalesce them).

What about the TCP_MAXSEG socket option, should that work? From a quick
look at driver source code, I could only see the handling of the
per-interface MTU, no per-socket segment size.

Thanks for the quick reply,
/Niels

--=20
Niels M=F6ller. PGP-encrypted email is preferred. Keyid C0B98E26.
Internet email is subject to wholesale government surveillance.
