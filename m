From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5] net: Remove explicit write references to sk/inet
 in ip_append_data
Date: Tue, 01 Mar 2011 06:31:18 +0100
Message-ID: <1298957478.2676.9.camel@edumazet-laptop>
References: <20110227110614.GA6246@gondor.apana.org.au>
	 <E1Pu1TI-0005Qj-T7@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:33741 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab1CAFbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 00:31:31 -0500
Received: by wwe15 with SMTP id 15so4023780wwe.1
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 21:31:30 -0800 (PST)
In-Reply-To: <E1Pu1TI-0005Qj-T7@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 19:41 +0800, Herbert Xu a =C3=A9cr=
it :
> net: Remove explicit write references to sk/inet in ip_append_data
>=20
> In order to allow simultaneous calls to ip_append_data on the same
> socket, it must not modify any shared state in sk or inet (other
> than those that are designed to allow that such as atomic counters).
>=20
> This patch abstracts out write references to sk and inet_sk in
> ip_append_data and its friends so that we may use the underlying
> code in parallel.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
>=20
>  include/net/inet_sock.h |   23 ++--
>  net/ipv4/ip_output.c    |  238 ++++++++++++++++++++++++++++---------=
-----------
>  2 files changed, 154 insertions(+), 107 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



