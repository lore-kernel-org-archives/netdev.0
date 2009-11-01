From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [net-next-2.6 PATCH v4 1/3] TCPCT part 1a: add request_values
 parameter for sending SYNACK
Date: Sun, 01 Nov 2009 20:13:02 +0100
Message-ID: <4AEDDDBE.70300@cosmosbay.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E474.9060704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45947 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbZKATNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 14:13:06 -0500
In-Reply-To: <4AE6E474.9060704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> Add optional function parameters associated with sending SYNACK.
> These parameters are not needed after sending SYNACK, and are not
> used for retransmission.  Avoids extending struct tcp_request_sock,
> and avoids allocating kernel memory.
>=20
> Also affects DCCP as it uses common struct request_sock_ops,
> but this parameter is currently reserved for future use.
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  include/net/request_sock.h      |    8 +++++++-
>  include/net/tcp.h               |    1 +
>  net/dccp/ipv4.c                 |    5 +++--
>  net/dccp/ipv6.c                 |    5 +++--
>  net/dccp/minisocks.c            |    2 +-
>  net/ipv4/inet_connection_sock.c |    2 +-
>  net/ipv4/tcp_ipv4.c             |   11 +++++++----
>  net/ipv4/tcp_minisocks.c        |    2 +-
>  net/ipv4/tcp_output.c           |    1 +
>  net/ipv6/tcp_ipv6.c             |   14 +++++++-------
>  10 files changed, 32 insertions(+), 19 deletions(-)
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
