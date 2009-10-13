From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add netdev_alloc_skb_ip_align() helper
Date: Tue, 13 Oct 2009 20:06:15 +0200
Message-ID: <4AD4C197.40608@gmail.com>
References: <1254969161-3609-1-git-send-email-thomas@wytron.com.tw>	<4ACD585B.5080106@gmail.com>	<20091013.034532.36362276.davem@davemloft.net>	<4AD49DFC.9020406@gmail.com> <20091013103037.475e2400@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37661 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760820AbZJMSHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 14:07:01 -0400
In-Reply-To: <20091013103037.475e2400@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> Name_is_getting_too_damn_long can we think of something beter.

yes probably

>=20
> Also, it isn't really ip alignment but compensating for the ethernet
> header.
>     alloc_ether_skb?

Dont know, but NET_IP_ALIGN was about making sure skb->data + sizeof(et=
hernet header)
is 4 bytes aligned, not for handling ethernet header itself in our stac=
k (we only need
2 bytes alignement for this ethernet header), but IP header.

=20

