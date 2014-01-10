From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: add link-local, sit and loopback address
 with INFINITY_LIFE_TIME
Date: Thu, 09 Jan 2014 23:09:01 -0500 (EST)
Message-ID: <20140109.230901.1342080649327666957.davem@davemloft.net>
References: <1389186135.88856.YahooMailBasic@web125506.mail.ne1.yahoo.com>
	<20140108144322.GJ9007@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fx.lebail@yahoo.com, netdev@vger.kernel.org,
	damien.wyart@gmail.com, yasushi.asano@jp.fujitsu.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbaAJEJC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 23:09:02 -0500
In-Reply-To: <20140108144322.GJ9007@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 8 Jan 2014 15:43:22 +0100

> In the past the IFA_PERMANENT flag indicated, that the valid and pref=
erred
> lifetime where ignored. Since change fad8da3e085ddf ("ipv6 addrconf: =
fix
> preferred lifetime state-changing behavior while valid_lft is infinit=
y")
> we honour at least the preferred lifetime on those addresses. As such
> the valid lifetime gets recalculated and updated to 0.
>=20
> If loopback address is added manually this problem does not occur.
> Also if NetworkManager manages IPv6, those addresses will get added v=
ia
> inet6_rtm_newaddr and thus will have a correct lifetime, too.
>=20
> Reported-by: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
> Reported-by: Damien Wyart <damien.wyart@gmail.com>
> Fixes: fad8da3e085ddf ("ipv6 addrconf: fix preferred lifetime state-c=
hanging behavior while valid_lft is infinity")
> Cc: Yasushi Asano <yasushi.asano@jp.fujitsu.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.

> I hope there will be another pull request to Linus before 3.13 (I thi=
nk
> there will be an upcoming -rc8 this Sunday?).

I think I will be able to sneak one more pull request in.
