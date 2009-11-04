From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] bridge: remove dev_put() in add_del_if()
Date: Wed, 04 Nov 2009 20:43:56 +0100
Message-ID: <4AF1D97C.6080603@gmail.com>
References: <4AF1D153.5040309@gmail.com> <20091104114020.5a2aef2c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36583 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757970AbZKDTnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 14:43:55 -0500
In-Reply-To: <20091104114020.5a2aef2c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
>=20
> As part of the general ref count purge sure.
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Yes, sure... but nf_queue.c is such an abuser that I doubt we
really can make dev_put() doing the atomic_dec_test() one day...
