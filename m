From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Tue, 09 Oct 2007 20:56:35 -0400
Message-ID: <470C2343.1020800@garzik.org>
References: <11916151232222-git-send-email-fubar@us.ibm.com> <470C200D.4010705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Moni Shoua <monis@voltaire.com>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40400 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282AbXJJA4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 20:56:47 -0400
In-Reply-To: <470C200D.4010705@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> applied patches 1-9
>=20
> the only thing that was a hiccup during submission is that your email=
=20
> subject lines did not contain a notion of ordering "[PATCH 1/9] ...".=
=20
> But other than that, the git-send-email went flawlessly.

unfortunately it does not seem to build flawlessly:


drivers/net/bonding/bond_main.c: In function =91bond_setup_by_slave=92:
drivers/net/bonding/bond_main.c:1264: error: =91struct net_device=92 ha=
s no=20
member named =91hard_header=92
drivers/net/bonding/bond_main.c:1264: error: =91struct net_device=92 ha=
s no=20
member named =91hard_header=92
drivers/net/bonding/bond_main.c:1265: error: =91struct net_device=92 ha=
s no=20
member named =91rebuild_header=92
drivers/net/bonding/bond_main.c:1265: error: =91struct net_device=92 ha=
s no=20
member named =91rebuild_header=92
drivers/net/bonding/bond_main.c:1266: error: =91struct net_device=92 ha=
s no=20
member named =91hard_header_cache=92
drivers/net/bonding/bond_main.c:1266: error: =91struct net_device=92 ha=
s no=20
member named =91hard_header_cache=92
drivers/net/bonding/bond_main.c:1267: error: =91struct net_device=92 ha=
s no=20
member named =91header_cache_update=92
drivers/net/bonding/bond_main.c:1267: error: =91struct net_device=92 ha=
s no=20
member named =91header_cache_update=92
drivers/net/bonding/bond_main.c:1268: error: =91struct net_device=92 ha=
s no=20
member named =91hard_header_parse=92
drivers/net/bonding/bond_main.c:1268: error: =91struct net_device=92 ha=
s no=20
member named =91hard_header_parse=92
drivers/net/bonding/bond_main.c: In function =91bond_release_and_destro=
y=92:
drivers/net/bonding/bond_main.c:1864: warning: too few arguments for fo=
rmat

