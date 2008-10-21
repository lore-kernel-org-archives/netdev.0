From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 22:15:43 +0200
Message-ID: <48FE386F.8090706@cosmosbay.com>
References: <20081020190922.7dd6510a@extreme> <20081020.221857.209830018.davem@davemloft.net> <48FE34AF.8050508@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, David Miller <davem@davemloft.net>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.48]:52743 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755314AbYJUUPw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 16:15:52 -0400
In-Reply-To: <48FE34AF.8050508@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones a =E9crit :
> David Miller wrote:
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Mon, 20 Oct 2008 19:09:22 -0700
>>
>>
>>> Add support for recycling tx buffers into receive buffers.
>>> This is experimental at this point.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>>
>> Experimental, but do you have any performance data at all?
>> Just curious...
>=20
> I've not had a good emily litella moment all day so I'll ask - is the=
re=20
> really that much in the way of suitable skb's which are completely fr=
ee=20
> after transmit completion?

Or, if we take another way, say a VOIP RTP machine sends and receive 20=
=2E000
 packets per second, each being 200 bytes long, are transmited packets
correctly sized at sendto() time to be candidates for recycling ?





