From: kuznet@ms2.inr.ac.ru
Subject: Re: raw ipv6 broken in 2.4.19
Date: Wed, 14 Aug 2002 02:00:06 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208132200.CAA22153@sex.inr.ac.ru>
References: <Pine.LNX.4.44.0208140004530.1212-100000@u.domain.uli>
Mime-Version: 1.0
Cc: gandalf@wlug.westbo.se, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: ja@ssi.bg (Julian Anastasov)
In-Reply-To: <Pine.LNX.4.44.0208140004530.1212-100000@u.domain.uli> from "Julian Anastasov" at Aug 14, 2 00:15:09 am
List-Id: netdev.vger.kernel.org

Hello!

> 	What about the known problem with csum_partial called
> with zero length.

Maybe it is known to you, but not to me.


>     (addr&2!=0 => bug)

Sorry? What do you mean? Checksumming routines must not have any alignment
constraints, they used with arbitrary combinations of alignments.

Alexey
