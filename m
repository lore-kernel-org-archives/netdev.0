From: apetlund@simula.no
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Fri, 30 Oct 2009 11:48:24 +0100
Message-ID: <6980f83370cc081eb82dc2e0bd65bcf4.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andreas Petlund" <apetlund@simula.no>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"Arnd Hannemann" <hannemann@nets.rwth-aachen.de>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	"David Miller" <davem@davemloft.net>
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757091AbZJ3KsZ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Just how thin can a thin stream be when a thin stream is found thin? (to
the
> cadence of "How much wood could a woodchuck chuck if a woodchuck could
chuck wood?")
>
> Does a stream get so thin that a user's send could not be split into
four,
> sub-MSS TCP segments?

That was a nifty idea: Anti-Nagle the segments to be able to trigger fast
retransmissions. I think it is possible.

Besides using more resources on each send, this scheme will introduce the
need to delay parts of the segment, which is undesirable for
time-dependent applications (the intended target of the mechanisms).

I think it would be fun to implement and play around with such a mechanism
to see the effects.

Regards,
Andreas
