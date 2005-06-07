From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Mon, 6 Jun 2005 23:50:16 -0700
Message-ID: <OF4AE6E385.33144EB9-ON88257019.0024BCE9-88257019.00258FFE@us.ibm.com>
References: <20050607.153359.82068814.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050607.153359.82068814.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Portable applications do like this:

> #ifdef IPV6_RECVHOPOPTS
> // RFC2292bis
> #else
> // RFC2292
> #endif

> --yoshfuji

I don't understand. If they do this, they'll
work already when recompiled (with the patch
I sent), won't they?

If they don't do this, old binaries will
return EINVAL on the setsockopt() calls that
have changed. And if they're going to edit
the source, they can do #ifdefs as above and
work again.

How does it help to renumber? I can renumber,
of course-- I just don't see how that does
anything.

                                        +-DLS
