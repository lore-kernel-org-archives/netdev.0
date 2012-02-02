From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] caif: Bugfix list_del_rcu race in
 cfmuxl_ctrlcmd.
Date: Thu, 02 Feb 2012 14:31:02 -0500 (EST)
Message-ID: <20120202.143102.1637418171061567370.davem@davemloft.net>
References: <1328181663-13853-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757007Ab2BBTbI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 14:31:08 -0500
In-Reply-To: <1328181663-13853-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Thu,  2 Feb 2012 12:21:02 +0100

> Always use cfmuxl_remove_uplayer when removing a up-layer.
> cfmuxl_ctrlcmd() can be called independently and in parallel with
> cfmuxl_remove_uplayer(). The race between them could cause list_del_r=
cu
> to be called on a node which has been already taken out from the list=
=2E
> That lead to a (rare) crash on accessing poisoned node->prev inside
> list_del_rcu.
>=20
> This fix ensures that deletion are done holding the same lock.
>=20
> Reported-by: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
