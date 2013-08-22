From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vlan: inherit addr_assign_type along with dev_addr
Date: Thu, 22 Aug 2013 11:49:20 -0700 (PDT)
Message-ID: <20130822.114920.610022099919624531.davem@davemloft.net>
References: <1377174201-20236-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730Ab3HVSt1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 14:49:27 -0400
In-Reply-To: <1377174201-20236-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 22 Aug 2013 14:23:21 +0200

> A vlan device inheriting a random or set address should reflect
> this in its addr_assign_type.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

I think this might deserve a helper function, I'd not be surprised
if we do MAC address propagation like this in other situations and
they have the same bug.
