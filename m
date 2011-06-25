From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cxgb3: skb_record_rx_queue now records the
 queue index relative to the net_device.
Date: Fri, 24 Jun 2011 18:04:28 -0700 (PDT)
Message-ID: <20110624.180428.232218988992689847.davem@davemloft.net>
References: <20110624003912.14349.62988.stgit@speedy5.asicdesigners.com>
	<1308891197.3000.2.camel@edumazet-laptop>
	<4E042036.1060907@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, jay@chelsio.com, netdev@vger.kernel.org,
	sbohrer@rgmadvisors.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45645 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab1FYBEj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 21:04:39 -0400
In-Reply-To: <4E042036.1060907@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Divy Le Ray <divy@chelsio.com>
Date: Thu, 23 Jun 2011 22:27:18 -0700

> On 6/23/2011 9:53 PM, Eric Dumazet wrote:
>> Le jeudi 23 juin 2011 =E0 17:39 -0700, John Hernandez a =E9crit :
>>> From: John (Jay) Hernandez<jay@chelsio.com>
>>>
>>> Fixed call to skb_record_rx_queue where we were passing the queue
>>> index
>>> relative to the adapter when it should have been relative to the
>>> net_device.
>>>
>>> Signed-off-by: John (Jay) Hernandez<jay@chelsio.com>
>>> Signed-off-by: Divy Le Ray<divy@chelsio.com>
>>>
>> Hmm, wasnt this bug reported by Shawn Bohrer ?
>=20
> Yes, it was.
>> Reported-by: Shawn Bohrer<sbohrer@rgmadvisors.com>
>>
>> Proper credits please ?
>=20
> Thanks for fixing this.

Applied, thanks.
