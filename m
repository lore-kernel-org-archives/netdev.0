From: steve@chygwyn.com
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
	sockets, and for IPv4 multicast forwarding
Date: Wed, 14 Oct 2009 08:23:19 +0100
Message-ID: <20091014072319.GA12095@fogou.chygwyn.com>
References: <200910071559.56526.atis@mikrotik.com> <20091007.135627.96995518.davem@davemloft.net> <55a4f86e0910071703i4735f1aan1ddba81eec7eef19@mail.gmail.com> <20091007.223928.34412707.davem@davemloft.net> <55a4f86e0910140051v69441b09gd364b32f8e2d0c68@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, atis@mikrotik.com,
	netdev@vger.kernel.org, panther@balabit.hu, eric.dumazet@gmail.com,
	brian.haley@hp.com
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:60447 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351AbZJNJSI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 05:18:08 -0400
Content-Disposition: inline
In-Reply-To: <55a4f86e0910140051v69441b09gd364b32f8e2d0c68@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Oct 14, 2009 at 12:51:56AM -0700, Maciej =C5=BBenczykowski wrot=
e:
> I'm thinking that the mark should be a tunnel parameter with values o=
f
> inherit or a constant.
>
Why not do this on a per-route basis (i.e. lets suppose we add a
"setmark" parameter to each route) and this would allow changing
a mark when a packet matches the route. This not only solves the
tunnel case, but would be generically useful as well.

Since we have to look up routes anyway, it shouldn't add any
real overhead to the routing process and we can benefit from
all the existing infrastructure (route cache, etc).

Steve.
