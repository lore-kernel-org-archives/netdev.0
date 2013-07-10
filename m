From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 13:40:35 +0200
Message-ID: <20130710114035.GB15411@order.stressinduktion.org>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <20130710111504.GA15411@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:36633 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586Ab3GJLkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 07:40:36 -0400
Content-Disposition: inline
In-Reply-To: <20130710111504.GA15411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 01:15:04PM +0200, Hannes Frederic Sowa wrote:
> On Wed, Jul 10, 2013 at 09:54:58AM +0200, Nicolas Dichtel wrote:
> > Le 09/07/2013 23:57, Hannes Frederic Sowa a =C3=A9crit :
> > >Are we sure we decrement all sibling's rt6i_nsiblings? Shouldn't w=
e
> > >start iterating from fn->leaf? But this does not seem to cause it,
> > >because my trace does not report any calls to fib6_del_route.
> > Note sure to follow you, but all siblings are listed in rt6i_siblin=
gs, so=20
> > it must be enough.
>=20
> My hunch was to iterate over fn->leaf->rt_next and compare the metric=
s like we
> do when adding a new route. Then take that rt6_info->rt6i_siblings li=
st_head
> to iterate over the remaining siblings. But I did not review that par=
t
> carefully, need to check later.

Just checked, it is fine.

I was distracted by the way the initial rt6_sibling list was constructe=
d.

Thanks,

  Hannes
