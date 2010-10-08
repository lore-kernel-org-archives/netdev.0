From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Fix rxq ref counting
Date: Fri, 08 Oct 2010 14:35:12 -0700 (PDT)
Message-ID: <20101008.143512.191408386.davem@davemloft.net>
References: <alpine.DEB.1.00.1010071304240.4792@pokey.mtv.corp.google.com>
	<1286485149.3745.93.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42103
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750806Ab0JHVev convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 17:34:51 -0400
In-Reply-To: <1286485149.3745.93.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Oct 2010 22:59:09 +0200

> Le jeudi 07 octobre 2010 =E0 13:09 -0700, Tom Herbert a =E9crit :
>> The rx->count reference is used to track reference counts to the
>> number of rx-queue kobjects created for the device.  This patch
>> eliminates initialization of the counter in netif_alloc_rx_queues
>> and instead increments the counter each time a kobject is created.
>> This is now symmetric with the decrement that is done when an object=
 is
>> released.
>>=20
>> Signed-off-by: Tom Herbert <therbert@google.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
