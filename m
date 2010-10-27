From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ehea: Fixing statistics
Date: Wed, 27 Oct 2010 14:21:41 -0700 (PDT)
Message-ID: <20101027.142141.104047821.davem@davemloft.net>
References: <20101027.113940.242117937.davem@davemloft.net>
	<1288205114-852-1-git-send-email-leitao@linux.vnet.ibm.com>
	<1288205610.2658.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41984
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932400Ab0J0VVS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 17:21:18 -0400
In-Reply-To: <1288205610.2658.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Oct 2010 20:53:30 +0200

> Le mercredi 27 octobre 2010 =E0 14:45 -0400, Breno Leitao a =E9crit :
>> (Applied over Eric's "ehea: fix use after free" patch)
>>=20
>> Currently ehea stats are broken. The bytes counters are got from
>> the hardware, while the packets counters are got from the device
>> driver. Also, the device driver counters are resetted during the
>> the down process, and the hardware aren't, causing some weird
>> numbers.
>>=20
>> This patch just consolidates the packets and bytes on the device
>> driver.
>>=20
>> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
>=20
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
