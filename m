From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [RFC PATCH net-2.6.26 2/3] [NET] NETNS: Omit sock->sk_net without
 CONFIG_NET_NS.
Date: Tue, 25 Mar 2008 18:46:53 +0300
Message-ID: <47E91E6D.7090609@openvz.org>
References: <20080325.231459.40431402.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36203 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755095AbYCYPrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 11:47:12 -0400
In-Reply-To: <20080325.231459.40431402.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Introduce per-sock inlines: sock_net(), sock_net_set().
> Without CONFIG_NET_NS, no namespace other than &init_net exists.
> Let's explicitly define them to help compiler optimizations.
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

Thanks!
