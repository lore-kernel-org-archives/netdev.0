From: Damien Wyart <damien.wyart@gmail.com>
Subject: Re: [PATCH net] ipv6: add link-local, sit and loopback address with
 INFINITY_LIFE_TIME
Date: Wed, 8 Jan 2014 17:12:43 +0100
Message-ID: <20140108161243.GA3694@brouette>
References: <1389186135.88856.YahooMailBasic@web125506.mail.ne1.yahoo.com>
 <20140108144322.GJ9007@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: =?iso-8859-1?Q?Fran=E7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	yasushi.asano@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhost-v5-p3.mangoosta.org ([195.5.209.90]:14498 "EHLO
	smtp-delay1.nerim.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756635AbaAHQUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 11:20:05 -0500
Received: from mallaury.nerim.net (smtp-103-wednesday.noc.nerim.net [178.132.17.103])
	by smtp-delay1.nerim.net (Postfix) with ESMTP id E23B522E083
	for <netdev@vger.kernel.org>; Wed,  8 Jan 2014 17:13:06 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20140108144322.GJ9007@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Hannes Frederic Sowa <hannes@stressinduktion.org> [2014-01-08 15:43]:
> In the past the IFA_PERMANENT flag indicated, that the valid and preferred
> lifetime where ignored. Since change fad8da3e085ddf ("ipv6 addrconf: fix
> preferred lifetime state-changing behavior while valid_lft is infinity")
> we honour at least the preferred lifetime on those addresses. As such
> the valid lifetime gets recalculated and updated to 0.

> If loopback address is added manually this problem does not occur.
> Also if NetworkManager manages IPv6, those addresses will get added via
> inet6_rtm_newaddr and thus will have a correct lifetime, too.

I confirm this patch (on top of 3.13-rc7+) fixes the problem on my
system, eth0 has a LLA adress again after boot and ::1 is back on the
loopback interface.

Thanks for the quick fix!

-- 
Damien Wyart
