From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 17:20:01 +0200
Message-ID: <20130710152001.GH15411@order.stressinduktion.org>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:37083 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab3GJPUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 11:20:03 -0400
Content-Disposition: inline
In-Reply-To: <51DD6B72.1050700@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 04:10:58PM +0200, Nicolas Dichtel wrote:
> Le 10/07/2013 15:21, Hannes Frederic Sowa a =C3=A9crit :
> >On Wed, Jul 10, 2013 at 02:22:55PM +0200, Nicolas Dichtel wrote:
> >>Le 10/07/2013 12:53, Hannes Frederic Sowa a =C3=A9crit :
> >The route with rt6i_gateway does actually expire because I got it fr=
om
> >autoconf and ip -6 r l confirms this, too. It seems this is only the=
 cached
> >route (I will confirm shortly). Is this still ok?
> I wonder why expires is 0. Even if this route is cached, the flag=20
> RTF_EXPIRES should be set. Am I wrong?

It seems it is possible cached route gets its expiration updated. As
such it is not counted in the iteration but it is found as a sibling an=
d its
nsiblings count is updated again.

(sorry for the additional mail, forgot to send it to the list)

Greetings,

  Hannes
