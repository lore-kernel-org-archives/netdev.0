From: Julian Anastasov <ja@ssi.bg>
Subject: Re: raw ipv6 broken in 2.4.19
Date: Wed, 14 Aug 2002 01:38:40 +0000 (GMT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208140125130.1701-100000@u.domain.uli>
References: <200208132218.CAA22224@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: gandalf@wlug.westbo.se, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200208132218.CAA22224@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 14 Aug 2002 kuznet@ms2.inr.ac.ru wrote:

> Well, if this is only in combination with zero length, it is not a disaster.

	May be. It seems there were no such callers but they
appeared. I'm not sure a comment can avoid further problems.
As for the fix, we don't see often lengths of 0 and 1 for
unaligned addrs, it is in the slow path in csum_partial. IMHO,
it will not hurt if we apply the fix instead of auditing everything.

> Alexey

Regards

--
Julian Anastasov <ja@ssi.bg>
