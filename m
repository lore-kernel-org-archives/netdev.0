From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same Port
Date: Thu, 3 Oct 2002 19:52:40 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210031552.TAA29921@sex.inr.ac.ru>
References: <20021004.001929.03389091.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: davem@redhat.com, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20021004.001929.03389091.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Oct 4, 2 00:19:29 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> test for daddr if for sk2.
> sk2 is iterator for existing sockets, which can be "connected."
> daddr can be non-zero, can't it?
> Am I wrong???

You are absolutely right.

But then I am put to coma. Now I do not understand the goal of the check.
Can you give a simple example showing what illegal case this check is supposed
to eliminate?

Actually, it would be great if you said what is wrong in that my patch?
It looks so simple that I am not ready to agree that real one should be
so complicated. :-)

Alexey
