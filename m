From: David Miller <davem@davemloft.net>
Subject: Re: [B.A.T.M.A.N.] [PATCH] Fix ARM BUILD_BUG_ON() errors
 withbatman-adv
Date: Mon, 02 Dec 2013 11:20:42 -0500 (EST)
Message-ID: <20131202.112042.875349112345949903.davem@davemloft.net>
References: <20131201171309.GD16735@n2100.arm.linux.org.uk>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7451@saturn3.aculab.com>
	<529C8226.2040000@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, linux@arm.linux.org.uk,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab3LBQUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 11:20:48 -0500
In-Reply-To: <529C8226.2040000@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Mon, 02 Dec 2013 13:50:46 +0100

> This may work with the structures I reported in a previous email, but
> it is not a good solution for us because we have other more complex
> substructs that cannot be packed that way.
> 
> I think we will simply duplicate the members and avoid substructs in
> our packets.

I would strongly suggest just making everything a multiple of 4 bytes in
size.
