From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 09:26:57 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209280526.JAA03028@sex.inr.ac.ru>
References: <20020928.141407.110833680.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: usagi@linux-ipv6.org, davem@redhat.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20020928.141407.110833680.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Sep 28, 2 02:14:07 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> we need per application (per socket) interface
> for privacy extension (public address vs temporary address) and 
> mobile ip (home address vs care-of address).

OK. It is natural user-friendly generalization of bind(). I do not see
problems.

Though, please, explain, to avoid misunderstanding. Let's take the second
case for simplicity. Is that true that it is supposed to add
to each application a switch "home or care-of"? This sound strange enough,
taking into account that only a few of applications have switch sort of -b
in openssh despite of age of plain bind() is equal to age of internet. :-)

Alexey
