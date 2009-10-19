From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4 v3] net: Introduce sk_tx_queue_mapping
Date: Mon, 19 Oct 2009 18:45:05 +0200
Message-ID: <4ADC9791.3030107@gmail.com>
References: <20091018130727.3960.32107.sendpatchset@localhost.localdomain> <20091018130740.3960.96469.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40175 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756984AbZJSQpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 12:45:17 -0400
In-Reply-To: <20091018130740.3960.96469.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> Introduce sk_tx_queue_mapping; and functions that set, test and
> get this value. Reset sk_tx_queue_mapping to -1 whenever the dst
> cache is set/reset, and in socket alloc. Setting txq to -1 and
> using valid txq=3D<0 to n-1> allows the tx path to use the value
> of sk_tx_queue_mapping directly instead of subtracting 1 on every
> tx.
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
