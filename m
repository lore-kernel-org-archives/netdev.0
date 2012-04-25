From: Tore Anderson <tore@fud.no>
Subject: Re: [PATCH net-next] ipv6: =?UTF-8?Q?RTAX=5FFEATURE=5FALLFRAG=20c?=  =?UTF-8?Q?auses=20inefficient=20TCP=20segment=20sizing?=
Date: Wed, 25 Apr 2012 11:51:37 +0200
Message-ID: <171c22af5ae0b0f70e7b81baad260de6@greed.fud.no>
References: <1335289058.5205.165.camel@edumazet-glaptop>
 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
 <1335298228.5205.168.camel@edumazet-glaptop>
 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
 <1335331960.5205.180.camel@edumazet-glaptop>
 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
 <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
 <1335346710.3274.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:55688 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757154Ab2DYJvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 05:51:42 -0400
In-Reply-To: <1335346710.3274.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet

> Hmm, but what if we change linux to choice a) instead of b) ?
>
> That is, not cap mtu to minimum value 1280 (and not use anymore
> RTAX_FEATURE_ALLFRAG) : dst_allfrag() would be always false.

Yep.

> In this case, do we still need to send the frag header ?

No - the (translated) IPv4 packet should then fit onto the small-MTU
IPv4 link without any fragmentation (by the IPv4 router) required. So
you end up with perfectly regular end-to-end Path MTU Discovery.

Tore
