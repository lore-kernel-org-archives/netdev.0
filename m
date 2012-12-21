From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 over Firewire
Date: Sat, 22 Dec 2012 02:53:29 +0900
Message-ID: <50D4A219.7080807@linux-ipv6.org>
References: <50D49659.1000101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33214 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751130Ab2LURxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 12:53:31 -0500
In-Reply-To: <50D49659.1000101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012=E5=B9=B412=E6=9C=8822=E6=97=A5 02:03), Stephan Gatzka wrote:

> To make the address mapping to the firewire link layer RFC3146 mandat=
es to use neighbor discovery with a certain format of the source/target=
 link-layer address option.
>=20
> While it is not too complicated to build that up, I'm wondering how I=
 can reserve enough memory in the corresponding skb.
>=20
> One possibility is to introduce some option padding in ndisc_addr_opt=
ion_pad() but I think that's somehow weird.
>=20
> The second option I see is to set needed_tailroom in struct netdevice=
 for firewire net devices. That's the way I would go for.
>=20
> Because I'm not really familiar with the whole network infrastructure=
 in Linux, a confirmation for the way to go would be nice.

If you are talking about how to build NS/NA/RS/Redirect messages, you
can just use ndisc_opt_addr_space() and ndisc_fill_addr_option() here.

--yoshfuji
