From: Julian Anastasov <ja@ssi.bg>
Subject: Re: raw ipv6 broken in 2.4.19
Date: Wed, 14 Aug 2002 01:12:41 +0000 (GMT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208140107570.1517-100000@u.domain.uli>
References: <200208132200.CAA22153@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: gandalf@wlug.westbo.se, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200208132200.CAA22153@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 14 Aug 2002 kuznet@ms2.inr.ac.ru wrote:

> > 	What about the known problem with csum_partial called
> > with zero length.
>
> Maybe it is known to you, but not to me.

	Hm, some links:

http://marc.theaimsgroup.com/?l=linux-kernel&m=99489362903633&w=2
http://marc.theaimsgroup.com/?l=linux-virtual-server&m=100332800916641&w=2

> >     (addr&2!=0 => bug)
>
> Sorry? What do you mean? Checksumming routines must not have any alignment
> constraints, they used with arbitrary combinations of alignments.

	Do you believe, they have :) See the 2nd URL, there is
a fix tested from Wensong (old LVS problem).

> Alexey

Regards

--
Julian Anastasov <ja@ssi.bg>
