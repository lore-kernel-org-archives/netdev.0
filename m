From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 2/3] TCPCT part 1b: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS, functions
Date: Sun, 01 Nov 2009 20:13:55 +0100
Message-ID: <4AEDDDF3.3070102@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E529.706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45950 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbZKATNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 14:13:55 -0500
In-Reply-To: <4AE6E529.706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> Define sysctl (tcp_cookie_size) to turn on and off the cookie option
> default globally, instead of a compiled configuration option.
>=20
> Define per socket option (TCP_COOKIE_TRANSACTIONS) for setting consta=
nt
> data values, retrieving variable cookie values, and other facilities.
>=20
> Redefine two TCP header functions to accept TCP header pointer.
> When subtracting, return signed int to allow error checking.
>=20
> Move inline tcp_clear_options() unchanged from net/tcp.h to linux/tcp=
=2Eh,
> near its corresponding struct tcp_options_received (prior to changes)=
=2E
>=20
> This is a straightforward re-implementation of an earlier (year-old)
> patch that no longer applies cleanly, with permission of the original
> author (Adam Langley).  The patch was previously reviewed:
>=20
>    http://thread.gmane.org/gmane.linux.network/102586
>=20
> These functions will also be used in subsequent patches that implemen=
t
> additional features.
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  Documentation/networking/ip-sysctl.txt |    8 +++++
>  include/linux/tcp.h                    |   47
> +++++++++++++++++++++++++++++++-
>  include/net/tcp.h                      |    6 +---
>  net/ipv4/sysctl_net_ipv4.c             |    8 +++++
>  net/ipv4/tcp_output.c                  |    8 +++++
>  5 files changed, 71 insertions(+), 6 deletions(-)
>=20

+#define TCP_EXTEND_TIMESTAMP	(1 << 4)	/* Initiate 64-bit timestamps */

What is this for ?

