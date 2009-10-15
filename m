From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH net-next-2.6] net: =?UTF-8?Q?sk=5Fdrops=20consolidation?=
Date: Thu, 15 Oct 2009 09:43:29 +0200
Message-ID: <70b57eea9586336e9a32b8e04afb9569@chewa.net>
References: <4AD68D4C.2080108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:34897 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757674AbZJOHoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 03:44:07 -0400
In-Reply-To: <4AD68D4C.2080108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 15 Oct 2009 04:47:40 +0200, Eric Dumazet <eric.dumazet@gmail.co=
m>=0D
wrote:=0D
> sock_queue_rcv_skb() can update sk_drops itself, removing need for=0D
> callers to take care of it. This is more consistent since=0D
> sock_queue_rcv_skb() also reads sk_drops when queueing a skb.=0D
> =0D
> This adds sk_drops managment to many protocols that not cared yet.=0D
=0D
=46or what it's worth, Phonet parts look fine to me.=0D
=0D
Acked-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

