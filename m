From: kuznet@ms2.inr.ac.ru
Subject: Re: net/ipv6/exthdrs.c
Date: Wed, 19 Jun 2002 13:42:20 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200206190942.NAA15342@sex.inr.ac.ru>
References: <1024478965.882.2.camel@arwen>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kisza@pannongsm.hu (Kis-Szabo Andras)
In-Reply-To: <1024478965.882.2.camel@arwen> from "Kis-Szabo Andras" at Jun 19, 2 11:30:39 am
List-Id: netdev.vger.kernel.org

Hello!

> The same behaviour as in NONE,

Yes, this is equivalent. And the function behaves exactly as you
expect then. :-)


> The ESP belongs to the headers, it is a member of a possible chain.

Like UDP, TCP (and NONE as you noticed). Not like headers mentioned
in ipv6_ext_hdr().


> - header match - i had to search for the ESP, too
> - ESP match - it has a public SPI value, which can be used in rules
> - general iteration, skipped together with the NONE.
> It terminates the header chain, but the existance of the ESP header and
> its SPI value are usefull information.

Hey, we spoke about _skip_. For all items mentioned by you ESP
is considered like UDP&TCP, not like extension header!


> about the nexthdr value and a new header parser/evaluator with strict
> size/pointer checks.

I feel you make something wrong yet. Or I do not understand something.

Alexey
