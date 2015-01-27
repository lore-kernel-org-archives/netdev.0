From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Tue, 27 Jan 2015 18:32:03 -0500
Message-ID: <20150127183203.31c7f2bbe9de4ffa9cfa138b@mindspring.com>
References: <1422327262-6344-1-git-send-email-fan.du@intel.com>
	<20150126.233938.513240875461315013.davem@davemloft.net>
	<54C741E4.2000009@gmail.com>
	<20150127.001226.711259930266409202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fengyuleidian0615@gmail.com, fan.du@intel.com,
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:53329 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752134AbbA0Xhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 18:37:39 -0500
In-Reply-To: <20150127.001226.711259930266409202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jan 2015, David Miller wrote:

> From: Fan Du <fengyuleidian0615@gmail.com>
> Date: Tue, 27 Jan 2015 15:44:36 +0800
>=20
> > =E4=BA=8E 2015=E5=B9=B401=E6=9C=8827=E6=97=A5 15:39, David Miller =E5=
=86=99=E9=81=93:
> >> From: Fan Du <fan.du@intel.com>
> >> Date: Tue, 27 Jan 2015 10:54:22 +0800
> >>
> >>> @@ -2419,6 +2419,11 @@ static int xfrm_user_rcv_msg(struct sk_buf=
f
> >>> *skb, struct nlmsghdr *nlh)
> >>>   	const struct xfrm_link *link;
> >>>   	int type, err;
> >>>
> >>> +#ifdef CONFIG_COMPAT
> >>> +	if (is_compat_task())
> >>> +		return -EPERM;
> >>> +#endif
> >>> +
> >>
> >> This seems more like an unsupported operation rather then a permis=
sion
> >> problem.
> >>
> > how about *ENOTSUPP* ?
>=20
> Unquestionably, that is an improvement over EPERM.

But it should be EOPNOTSUPP rather than ENOTSUP, right?

					-Bill
