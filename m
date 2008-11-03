From: Stephen Hemminger <shemminger@vyatta.com>
Subject: warnings from recent format patch
Date: Sun, 2 Nov 2008 16:33:11 -0800
Message-ID: <20081102163311.44e4ddef@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46290 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753930AbYKCAdR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 19:33:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if you can't run it, please compile and run sparse on your
code.

 CC [M]  net/sunrpc/xprtsock.o
net/sunrpc/xprtsock.c: In function =E2=80=98xs_format_ipv4_peer_address=
es=E2=80=99:
net/sunrpc/xprtsock.c:287: warning: too many arguments for format

static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
					  const char *protocol,
					  const char *netid)
{
	struct sockaddr_in *addr =3D xs_addr_in(xprt);
	char *buf;

	buf =3D kzalloc(20, GFP_KERNEL);
	if (buf) {
		snprintf(buf, 20, "pI4", &addr->sin_addr.s_addr);
                                   ^
                                   missing %
