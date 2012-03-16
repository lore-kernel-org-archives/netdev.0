From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/usbnet: reserve headroom on rx skbs
Date: Fri, 16 Mar 2012 02:02:10 -0700 (PDT)
Message-ID: <20120316.020210.382790286150729745.davem@davemloft.net>
References: <1331744185.6022.25.camel@edumazet-glaptop>
	<201203151801.03399.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965068Ab2CPJCS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 05:02:18 -0400
In-Reply-To: <201203151801.03399.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Oliver Neukum <oneukum@suse.de>
Date: Thu, 15 Mar 2012 18:01:03 +0100

> Am Mittwoch, 14. M=E4rz 2012, 17:56:25 schrieb Eric Dumazet:
>> network drivers should reserve some headroom on incoming skbs so tha=
t we
>> dont need expensive reallocations, eg forwarding packets in tunnels.
>>=20
>> This NET_SKB_PAD padding is done in various helpers, like
>> __netdev_alloc_skb_ip_align() in this patch, combining NET_SKB_PAD a=
nd
>> NET_IP_ALIGN magic.
>>=20
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Oliver Neukum <oneukum@suse.de>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Acked-by: Oliver Neukum <oneukum@suse.de>

Applied.
