From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] net: heap overflow in __audit_sockaddr()
Date: Thu, 03 Oct 2013 16:06:30 -0400 (EDT)
Message-ID: <20131003.160630.358364383240386879.davem@davemloft.net>
References: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com>
	<20131002212720.GA30492@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, security@kernel.org, juri.aedla@gmail.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548Ab3JCUGc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 16:06:32 -0400
In-Reply-To: <20131002212720.GA30492@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 3 Oct 2013 00:27:20 +0300

> We need to cap ->msg_namelen or it leads to a buffer overflow when we
> to the memcpy() in __audit_sockaddr().  It requires CAP_AUDIT_CONTROL=
 to
> exploit this bug.
>=20
> The call tree is:
> ___sys_recvmsg()
>   move_addr_to_user()
>     audit_sockaddr()
>       __audit_sockaddr()
>=20
> Reported-by: J=FCri Aedla <juri.aedla@gmail.com>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: The limit check to the compat code was missing as pointed out by
> Ben Hutchings.

Applied and queued up for -stable, thanks Dan.
