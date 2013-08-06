From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ip_gre: fix ipgre_header to return correct offset
Date: Tue, 06 Aug 2013 04:37:13 -0700
Message-ID: <1375789033.4457.87.camel@edumazet-glaptop>
References: <1375785943-23908-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:43558 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab3HFLhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 07:37:15 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so293954pbb.20
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 04:37:14 -0700 (PDT)
In-Reply-To: <1375785943-23908-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 13:45 +0300, Timo Ter=C3=A4s wrote:
> Fix ipgre_header() (header_ops->create) to return the correct
> amount of bytes pushed. Most callers of dev_hard_header() seem
> to care only if it was success, but af_packet.c uses it as
> offset to the skb to copy from userspace only once. In practice
> this fixes packet socket sendto()/sendmsg() to gre tunnels.
>=20
> Regression introduced in c54419321455631079c7d6e60bc732dd0c5914c5
> ("GRE: Refactor GRE tunneling code.")
>=20
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> ---
> Should go to 3.10-stable too. Without this dmvpn setup does not work
> at all, as opennhrp uses packet sockets to send the nhrp packets.
>=20
>  net/ipv4/ip_gre.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>
