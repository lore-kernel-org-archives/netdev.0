From: kuznet@ms2.inr.ac.ru
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Tue, 14 Jan 2003 04:22:52 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301140122.EAA10371@sex.inr.ac.ru>
References: <Pine.LNX.4.33.0301131609290.1861-100000@dyn9-47-18-98.beaverton.ibm.com>
Mime-Version: 1.0
Cc: sri@us.ibm.com, jgrimm2@us.ibm.com, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sri@us.ibm.com (Sridhar Samudrala)
In-Reply-To: <Pine.LNX.4.33.0301131609290.1861-100000@dyn9-47-18-98.beaverton.ibm.com> from "Sridhar Samudrala" at Jan 13, 3 04:49:33 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Is this more agreeable?

I did not disagree with the first one, actually. :-)
It was cleaner, to be honest.

In any case, after reading mail by Jon Grimm, the things
became cleaner. BTW what is "chunk" size in current implementation?

Essentially, to make a compromise between usability and sanity,
it is enough to make the thing which we make with UDP: to prevent
sending bogus fragmented packets when IP_MTUDISC_DO is set by user
and set chunk size to a value < min(512,current mtu) in this case,
so no fragments will be generated. In that case I will be happy
(done all that possible, all the flaws are directed to SCTP designers. :-))
and default behaviour (it is IP_MTUDISC_WANT) still will be rfc compliant.


> If not, do you prefer SCTP having its own ip_xmit

Hey, only not this. :-)

BTW what did you make with IPv6? We even not have any analogue
to ip_fragment there at the moment. Do not worry, we have to do this
in any case, not depending on SCTP demands. :-)

Alexey
