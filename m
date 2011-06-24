From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH net-2.6] cxgb3: skb_record_rx_queue now records the queue
 index relative to the net_device.
Date: Thu, 23 Jun 2011 22:27:18 -0700
Message-ID: <4E042036.1060907@chelsio.com>
References: <20110624003912.14349.62988.stgit@speedy5.asicdesigners.com> <1308891197.3000.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Hernandez <jay@chelsio.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5517 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab1FXGaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 02:30:21 -0400
In-Reply-To: <1308891197.3000.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/23/2011 9:53 PM, Eric Dumazet wrote:
> Le jeudi 23 juin 2011 =C3=A0 17:39 -0700, John Hernandez a =C3=A9crit=
 :
>> From: John (Jay) Hernandez<jay@chelsio.com>
>>
>> Fixed call to skb_record_rx_queue where we were passing the queue in=
dex
>> relative to the adapter when it should have been relative to the net=
_device.
>>
>> Signed-off-by: John (Jay) Hernandez<jay@chelsio.com>
>> Signed-off-by: Divy Le Ray<divy@chelsio.com>
>>
> Hmm, wasnt this bug reported by Shawn Bohrer ?

Yes, it was.
> Reported-by: Shawn Bohrer<sbohrer@rgmadvisors.com>
>
> Proper credits please ?

Thanks for fixing this.

cheers,
Divy

