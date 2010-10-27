From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: fix use after free
Date: Wed, 27 Oct 2010 11:39:40 -0700 (PDT)
Message-ID: <20101027.113940.242117937.davem@davemloft.net>
References: <1288118920.2652.4.camel@edumazet-laptop>
	<1288156867.2652.127.camel@edumazet-laptop>
	<4CC84DCF.1070806@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754739Ab0J0SjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:39:17 -0400
In-Reply-To: <4CC84DCF.1070806@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Wed, 27 Oct 2010 14:05:35 -0200

>> [PATCH] ehea: fix use after free
>>
>> ehea_start_xmit() dereferences skb after its freeing in ehea_xmit3()
>> to
>> get vlan tags.
>>
>> Move the offending block before the potential ehea_xmit3() call.
>>
>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied, thanks.
