From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: Re: [PATCH net-next-2.6 take2] ipv6: udp: Optimise multicast reception
Date: Fri, 6 Nov 2009 19:59:57 +0200
Message-ID: <200911061959.57326.lgrijincu@ixiacom.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <4AF45BDE.4090501@gmail.com> <4AF462EF.1050604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	opurdila@ixiacom.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:6031 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755630AbZKFR7x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 12:59:53 -0500
In-Reply-To: <4AF462EF.1050604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=CEn data de Vin 06 Noi 2009 19:54:55 Eric Dumazet a scris:
> We should atomic_inc(&sk->sk_drops) in the case skb_clone()
> could not provide a copy, and eventually increment UDP_MIB_RCVBUFERRO=
RS &
> UDP_MIB_INERRORS SNMP counters

Shouldn't this be also done if udp_queue_rcv_skb() returned a failure c=
ode (a=20
positive number) instead of silently droping?

--=20
Lucian
