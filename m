From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] net/usbnet: reserve headroom on rx skbs
Date: Thu, 15 Mar 2012 18:01:03 +0100
Message-ID: <201203151801.03399.oneukum@suse.de>
References: <1331744185.6022.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45696 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161096Ab2CORBH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 13:01:07 -0400
In-Reply-To: <1331744185.6022.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 14. M=C3=A4rz 2012, 17:56:25 schrieb Eric Dumazet:
> network drivers should reserve some headroom on incoming skbs so that=
 we
> dont need expensive reallocations, eg forwarding packets in tunnels.
>=20
> This NET_SKB_PAD padding is done in various helpers, like
> __netdev_alloc_skb_ip_align() in this patch, combining NET_SKB_PAD an=
d
> NET_IP_ALIGN magic.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Oliver Neukum <oneukum@suse.de>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Acked-by: Oliver Neukum <oneukum@suse.de>
