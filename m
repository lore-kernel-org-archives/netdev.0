From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet_peer: Optimize inet_getid()
Date: Mon, 05 Oct 2009 09:38:56 +0200
Message-ID: <4AC9A290.3080204@gmail.com>
References: <4ABBC2D8.2040901@gmail.com>	<20090924123020.59a2ee6e@s6510>	<4ABBDA45.2040109@gmail.com> <20091005.000818.95127796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46067 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbZJEHjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:39:36 -0400
In-Reply-To: <20091005.000818.95127796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
>=20
> I can't apply this, it's going to break the build on some
> architectures.
>=20
> For example, sparc64 only supports cmpxchg on u32 and u64
> objects, but you're trying to use it on a u16 here.

Oops, thanks for the info David !
