From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Fix suspicious RCU usage in fib_rebalance
Date: Fri, 16 Oct 2015 01:03:05 -0700 (PDT)
Message-ID: <20151016.010305.37587294372313844.davem@davemloft.net>
References: <1444866240-31778-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pch@ordbogen.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbbJPHq4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:46:56 -0400
In-Reply-To: <1444866240-31778-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 14 Oct 2015 16:44:00 -0700

> This command:
>   ip route add 192.168.1.0/24 nexthop via 10.2.1.5 dev eth1 nexthop v=
ia 10.2.2.5 dev eth2
>=20
> generated this suspicious RCU usage message:
 ...
> It looks like all of the code paths to fib_rebalance are under rtnl.
>=20
> Fixes: 0e884c78ee19 ("ipv4: L3 hash-based multipath")
> Cc: Peter N=F8rlund <pch@ordbogen.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
