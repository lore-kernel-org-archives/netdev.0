From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] caif: Bugfix double kfree_skb upon xmit failure
Date: Thu, 02 Feb 2012 14:31:07 -0500 (EST)
Message-ID: <20120202.143107.1749468353004654787.davem@davemloft.net>
References: <1328181663-13853-1-git-send-email-sjur.brandeland@stericsson.com>
	<1328181663-13853-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	dmitry.tarnyagin@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014Ab2BBTbO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 14:31:14 -0500
In-Reply-To: <1328181663-13853-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Thu,  2 Feb 2012 12:21:03 +0100

> From: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
>=20
> SKB is freed twice upon send error. The Network stack consumes SKB ev=
en
> when it returns error code.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
