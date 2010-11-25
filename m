From: nisse@lysator.liu.se (Niels =?iso-8859-1?Q?M=F6ller?=)
Subject: Re: TCP_MAXSEG vs TCP/generic segmentation offload (tso/gso)
Date: Thu, 25 Nov 2010 17:25:42 +0100
Message-ID: <nn1v69qsjd.fsf@stalhein.lysator.liu.se>
References: <nny68hqzzn.fsf@stalhein.lysator.liu.se>
	<1290695253.2858.336.camel@edumazet-laptop>
	<nnaakxqw1u.fsf@stalhein.lysator.liu.se>
	<1290698312.2858.341.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290698312.2858.341.camel@edumazet-laptop> (Eric Dumazet's
	message of "Thu, 25 Nov 2010 16:18:31 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> I believe TCP_MAXSEG is working fine, but GRO/GSO dont care at all :
> They coalesce frames whatever their size is.

I was under the impression that TSO (and maybe GSO) implied more
cleverness in the network card; that the network card more or less gets
to decide by itself how to divide a tcp stream into segments. And for
example in the atl1c driver which I looked a bit into, this was what th=
e
REG_MTU register was for. Seems I have gotten this totally wrong.

Maybe Documentation/networking/netdevices.txt could clarify how it
works. Currently, it says

: Segmentation Offload (GSO, TSO) is an exception to this rule.  The
: upper layer protocol may pass a large socket buffer to the device
: transmit routine, and the device will break that up into separate
: packets based on the current MTU.

Regards, and thanks for your patience,
/Niels

--=20
Niels M=F6ller. PGP-encrypted email is preferred. Keyid C0B98E26.
Internet email is subject to wholesale government surveillance.
