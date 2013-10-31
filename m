From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: remove the unnecessary statement in find_match()
Date: Thu, 31 Oct 2013 09:45:37 +0100
Message-ID: <20131031084537.GA17210@order.stressinduktion.org>
References: <5270B7AE.9020801@cn.fujitsu.com> <20131030.170837.1882918923249091614.davem@davemloft.net> <20131030211157.GA13902@order.stressinduktion.org> <20131031.002234.45924350853188128.davem@davemloft.net> <5271F263.4020800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40542 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3JaIpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 04:45:39 -0400
Content-Disposition: inline
In-Reply-To: <5271F263.4020800@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 31, 2013 at 02:02:11PM +0800, Duan Jiong wrote:
> =E4=BA=8E 2013=E5=B9=B410=E6=9C=8831=E6=97=A5 12:22, David Miller =E5=
=86=99=E9=81=93:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Wed, 30 Oct 2013 22:11:57 +0100
> >=20
> >> On Wed, Oct 30, 2013 at 05:08:37PM -0400, David Miller wrote:
> >>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> >>> Date: Wed, 30 Oct 2013 15:39:26 +0800
> >>>
> >>>>
> >>>> After reading the function rt6_check_neigh(), we can
> >>>> know that the RT6_NUD_FAIL_SOFT can be returned only
> >>>> when the IS_ENABLE(CONFIG_IPV6_ROUTER_PREF) is false.
> >>>> so in function find_match(), there is no need to execute
> >>>> the statement !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF).
> >>>>
> >>>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> >>>
> >>> Applied to net-next, thanks.
> >>>
> >>> CONFIG_IPV6_ROUTER_PREF is another good candidate for Kconfig
> >>> removal.  I know we've had several bugs that only apply when
> >>> this option is on vs. off.  We're maintaining two different
> >>> code paths, for really no good reason.
> >>
> >> I agree and actually thought about that yesterday. Do you think a =
sysctl
> >> is a good option?
> >=20
> > Every distribution ships with the Kconfig option on, and no sysctl
> > exists currently to control it.
> >=20
> > So I'd say it's not necessary at all, or at the very least let's ha=
ve
> > someone come forward with a real rather than theoretical use case f=
or
> > such a feature before adding it.
> >=20
> > Actually, if RFC 4191 has the usual language like "there SHOULD be
> > an administrative mechanism to disable blah blah blah" I could
> > be convinced to add it now.  Can someone take a look?
>=20
> It seems that there is no such an administrative mechanism in RFC 419=
1.
>=20
> By the way, if the sysctl is used, we are still maintaining two diffe=
rent
> code paths, isn't it? so i think David's idea is good.

Makes life easier, no objections from me.

Greetings,

  Hannes
