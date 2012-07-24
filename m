From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 2/3] net: Make skb->skb_iif always track skb->dev
Date: Tue, 24 Jul 2012 23:43:25 +0200
Message-ID: <500F16FD.9070506@gmail.com>
References: <20120723.164542.1890653324956444632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ja@ssi.bg, Jiri Pirko <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42575 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753614Ab2GXVmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 17:42:16 -0400
Received: by weyx8 with SMTP id x8so33120wey.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 14:42:15 -0700 (PDT)
In-Reply-To: <20120723.164542.1890653324956444632.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/07/2012 01:45, David Miller a =E9crit :
>
> Make it follow device decapsulation, from things such as VLAN and
> bonding.
>
> The stuff that actually cares about pre-demuxed device pointers, is
> handled by the "orig_dev" variable in __netif_receive_skb().  And
> the only consumer of that is the po->origdev feature of AF_PACKET
> sockets.
>
> Signed-off-by: David S. Miller<davem@davemloft.net>

Jiri tried to remove this orig_dev usage in af_packet in march 2011, wi=
thout success, by using the=20
value of skb_iif instead :-)

In case my opinion might be relevant:

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

	Nicolas.
