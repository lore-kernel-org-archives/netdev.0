From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPV6_V6ONLY Support, v2 (is Re: [PATCH] IPv6: Allow Both
Date: Thu, 24 Oct 2002 20:24:11 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210241624.UAA02873@sex.inr.ac.ru>
References: <Pine.LNX.4.44.0210231312070.28208-100000@netcore.fi>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.org, davem@redhat.com, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.44.0210231312070.28208-100000@netcore.fi> from "Pekka Savola" at Oct 23, 2 01:15:26 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

Late question:

> ::, at least previously.  That worked e.g. on BSD.  Does that work now, 
> too?

Provided it uses IPV6_V6ONLY.


> tcp4       0      0  127.0.0.1.53           *.*                    LISTEN
> tcp4       0      0  193.166.4.206.53       *.*                    LISTEN
> tcp4       0      0  193.166.187.10.53      *.*                    LISTEN
> tcp6       0      0  *.53                   *.*                    LISTEN
...
> Will this work too?

No.

The question follows: what the hell does it make this? What is special
in ipv4 that it needs to bind to its addresses? With IPV6_V6ONLY connections
to all the IPv4 addresses but listed ones will be refused. I guess it is
not _that_ thing which bind expects.

Alexey
