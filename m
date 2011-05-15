From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 00/10] caif: rcu, refactoring and bugfixes
Date: Sun, 15 May 2011 17:48:14 -0400 (EDT)
Message-ID: <20110515.174814.2153231984820209172.davem@davemloft.net>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab1EOVsT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 17:48:19 -0400
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Fri, 13 May 2011 14:43:58 +0200

> This patch-set introduces RCU in the CAIF stack and
> fixes problems found when removing CAIF Link layer during traffic.
>=20
> The pattern used for RCU is mostly this:
> 	rcu_read_lock();
> 	p =3D get();
> 	hold(p);
> 	rcu_read_unlock();
> 	use(p);
> 	put(p);
>=20
> And when freeing:
> 	synchronize_rcu();
> 	wait_refcnt(p);
> 	kfree(p);

Series applied, thanks.
