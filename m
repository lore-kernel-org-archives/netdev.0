From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: Add netdev_alloc_skb_ip_align() helper
Date: Tue, 13 Oct 2009 10:30:37 -0700
Message-ID: <20091013103037.475e2400@s6510>
References: <1254969161-3609-1-git-send-email-thomas@wytron.com.tw>
	<4ACD585B.5080106@gmail.com>
	<20091013.034532.36362276.davem@davemloft.net>
	<4AD49DFC.9020406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48622 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760756AbZJMRbT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 13:31:19 -0400
In-Reply-To: <4AD49DFC.9020406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Oct 2009 17:34:20 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> David Miller a =C3=A9crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 08 Oct 2009 05:11:23 +0200
> >=20
> >> [PATCH] net: Add netdev_alloc_skb_ip_align() helper
> >>
> >> Instead of hardcoding NET_IP_ALIGN stuff in various network driver=
s, we can
> >> add a helper around netdev_alloc_skb()
> >>
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > Applied to net-next-2.6
>=20
> Thanks, here is the followup cleanup patch to use this new helper
>=20
> [PATCH net-next-2.6] net: Use netdev_alloc_skb_ip_align()
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Name_is_getting_too_damn_long can we think of something beter.

Also, it isn't really ip alignment but compensating for the ethernet
header.
    alloc_ether_skb?



