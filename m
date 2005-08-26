From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Route cache performance
Date: Fri, 26 Aug 2005 15:55:20 +0400
Message-ID: <20050826115520.GA12351@yakov.inr.ac.ru>
References: <20050815213855.GA17832@netnation.com> <43014E27.1070104@cosmosbay.com> <20050823190852.GA20794@netnation.com> <17163.32645.202453.145416@robur.slu.se> <20050824000158.GA8137@netnation.com> <20050825181111.GB14336@netnation.com> <20050825200543.GA6612@yakov.inr.ac.ru> <20050825212211.GA23384@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
Content-Disposition: inline
In-Reply-To: <20050825212211.GA23384@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> What part of the code will decrement the count?  I can't see it.

It depends. In the case of forwarding, it is kfree_skb(), happening
after the packet is transmitted by output device.

Well, it could result in overflow only if device queue is longer
than route/max_size.

Alexey
