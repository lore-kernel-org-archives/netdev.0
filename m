From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: increment UDP_MIB_NOPORTS in mcast receive
Date: Wed, 03 Oct 2012 15:30:28 -0400 (EDT)
Message-ID: <20121003.153028.2073042642990268368.davem@davemloft.net>
References: <OF8CC7A8E7.DA3B059E-ON85257A8C.004C258C-85257A8C.004DCE49@us.ibm.com>
	<1349278153.12401.2811.camel@edumazet-glaptop>
	<OFFFC99DDA.1BD04FA3-ON85257A8C.005A8E9B-85257A8C.00604444@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, chris2553@googlemail.com, davej@redhat.com,
	gpiez@web.de, ja@ssi.bg, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab2JCTab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 15:30:31 -0400
In-Reply-To: <OFFFC99DDA.1BD04FA3-ON85257A8C.005A8E9B-85257A8C.00604444@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 3 Oct 2012 13:31:30 -0400

> Eric Dumazet <eric.dumazet@gmail.com> wrote on 10/03/2012 11:29:13 AM:
> 
>> >         Of course. I think our difference is on the definition of 
>> > "receives".
>> 
>> A receive is a packet delivered to this host.
>> Interface being promiscuous or not doesnt really matter.
> 
>         A receive is a packet *addressed* to this host.

Although I'm largely ambivalent, this one sentence tipped me over
towards David's side on this issue.

But this is easy to resolve Eric, just simply make a new custom
counter that counts these new cases you care about and document it
properly.

Thanks.
