From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Disable router anycast address for /127 prefixes
Date: Thu, 07 Jul 2011 04:15:50 -0700 (PDT)
Message-ID: <20110707.041550.755359452689118458.davem@davemloft.net>
References: <4E0E1B85.1080906@hp.com>
	<87r569rpis.fsf@nemi.mork.no>
	<1309943053-21437-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	herbert@gondor.hengli.com.au, brian.haley@hp.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755650Ab1GGLRJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 07:17:09 -0400
In-Reply-To: <1309943053-21437-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed,  6 Jul 2011 11:04:13 +0200

> RFC 6164 requires that routers MUST disable Subnet-Router anycast
> for the prefix when /127 prefixes are used.
>=20
> No need for matching code in addrconf_leave_anycast() as it
> will silently ignore any attempt to leave an unknown anycast
> address.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied to net-next-2.6, thanks.
