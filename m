From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Wed, 16 Jul 2003 03:32:03 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307152332.DAA09710@dub.inr.ac.ru>
References: <Pine.LNX.4.44.0307152029580.14070-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.44.0307152029580.14070-100000@netcore.fi> from "Pekka Savola" at éÀÌ 15, 2003 10:26:21 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Such addresses are link-locals, of link local scope only.  A link-local 
> IPv6 address is awfully difficult to remember and type for all of your 
> possible links.
> 
> The only reasonable value user could supply is a global address.

So what? I do not see connection to previous. You want to live with global
addresses as nexthop? OK. But I remember you have spoken something quite
opposite yesterday.


> Please describe what you mean by "real IPv6 6to4 addresses".
...
> If the node processing those as a next-hop supports 6to4 and has the sit0
> pseudointerface configured, the address will be but through the special
> handling.
> 
> If the node doesn't support 6to4 or doesn't have the sit0 pseudointerface 
> configured, the address will be processed as normal, as any other IPv6 
> nexthop.
> 
> Right?

I do not understand why did you ask previous question. You answered to
this.


> Redundant information can be ignored.  This is not computer science
> theory, removing everything which is not directly relevant.  The use of
> the same representation for the next-hop (2002:F00:BA::x) as an address
> (2002:BA:F00:y) is the only logical, user-friendly way.

What a bullshit... The second is address of host "x". The first is supposed
to be address of host F00:BA, whatever it is. Probably, you can decrypt
this only because poisoned by computer science. :-)

Just to complete discussion, let's stay on format fe80::A.B.C.D, for example.
Unlike anothers it is 100% logically clean. :-)

Alexey
