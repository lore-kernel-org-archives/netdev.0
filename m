From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH netnext-2.6] bonding: change bond_create_proc_entry()
 to return void
Date: Tue, 13 Oct 2009 00:45:14 -0700 (PDT)
Message-ID: <20091013.004514.103922409.davem@davemloft.net>
References: <b9df5fa10910091910u1b6bf14bg2781cb12c58b21f9@mail.gmail.com>
	<1255207307-5976-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, rakib.mullick@gmail.com
To: nicolas.2p.debian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34992
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758368AbZJMHpS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 03:45:18 -0400
In-Reply-To: <1255207307-5976-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Date: Sat, 10 Oct 2009 22:41:47 +0200

> The function bond_create_proc_entry is currently of type int.
>=20
> Two versions of this function exist:
>=20
> The one in the ifdef CONFIG_PROC_FS branch always return 0.
> The one in the else branch (which is empty) return nothing.
>=20
> When CONFIG_PROC_FS is undef, this cause the following warning:
>=20
> drivers/net/bonding/bond_main.c: In function `bond_create_proc_entry'=
:
> drivers/net/bonding/bond_main.c:3393: warning: control reaches end of
> non-void function
>=20
> No caller of this function use the returned value.
>=20
> So change the returned type from int to void and remove the
> useless return 0; .
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
> Reported-by: Rakib Mullick <rakib.mullick@gmail.com>

Applied, thanks.
