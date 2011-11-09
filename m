From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] net-netlink: fix tos/tclass for dual-stack ipv6
 sockets
Date: Wed, 09 Nov 2011 15:35:30 -0500 (EST)
Message-ID: <20111109.153530.2283817573824031015.davem@davemloft.net>
References: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
	<1320716800-9151-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932304Ab1KIUfe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 15:35:34 -0500
In-Reply-To: <1320716800-9151-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon,  7 Nov 2011 17:46:40 -0800

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> Something along the following lines would be needed.
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

This is terrible, see my other email, inet->tos doesn't matter even
for mapped ipv6 sockets.
