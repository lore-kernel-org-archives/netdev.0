From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Thu, 17 Jul 2003 04:20:46 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307170020.EAA12924@dub.inr.ac.ru>
References: <Pine.LNX.4.44.0307160905330.20100-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.44.0307160905330.20100-100000@netcore.fi> from "Pekka Savola" at Jul 16, 2003 09:12:04 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Yes, I dare to say that they're a requirement. 

Nope. IPv6 host routing is based on assumption of link-locality
of the next hop. Probably, you want to read some rfcs or to look into code.

> the user space tools' problem: i.e. make them resolve a globally addressed 
> nexthop to a link-local nexthop.

Impossible, as I said.

[ NOTE, the subject changed back to correct one at this point. Seems,
  one sentence, written by me has grown to some huge tumor eating
  original one completely. :-) ]


> specifications use and the *users* want and need to use.

Sigh, there no specifications about tricks used by Linux routing tables,
*users* are unlikely to want to use this feature at all, as Mika noticed.
And when they want, they want to right:

    ip route add 3ffe::.... via 193.233.7.65

rather than crap sort of

    ip route add 3ffe::.... via 2002:<something in latin>

I do not understand, what the hell is going on with you.
I am already sorry that started this. :-)

Alexey
