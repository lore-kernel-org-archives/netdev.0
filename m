From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip_gre: fix ipgre_header to return correct offset
Date: Fri, 09 Aug 2013 11:06:01 -0700 (PDT)
Message-ID: <20130809.110601.2199167168539636757.davem@davemloft.net>
References: <1375785943-23908-1-git-send-email-timo.teras@iki.fi>
	<1375789033.4457.87.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org, pshelar@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758574Ab3HISGD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:06:03 -0400
In-Reply-To: <1375789033.4457.87.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Aug 2013 04:37:13 -0700

> On Tue, 2013-08-06 at 13:45 +0300, Timo Ter=E4s wrote:
>> Fix ipgre_header() (header_ops->create) to return the correct
>> amount of bytes pushed. Most callers of dev_hard_header() seem
>> to care only if it was success, but af_packet.c uses it as
>> offset to the skb to copy from userspace only once. In practice
>> this fixes packet socket sendto()/sendmsg() to gre tunnels.
>>=20
>> Regression introduced in c54419321455631079c7d6e60bc732dd0c5914c5
>> ("GRE: Refactor GRE tunneling code.")
>>=20
>> Cc: Pravin B Shelar <pshelar@nicira.com>
>> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
>> ---
>> Should go to 3.10-stable too. Without this dmvpn setup does not work
>> at all, as opennhrp uses packet sockets to send the nhrp packets.
>>=20
>>  net/ipv4/ip_gre.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
