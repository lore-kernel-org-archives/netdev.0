From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 21:13:15 +0100
Message-ID: <20110218201314.GD2602@psychotron.redhat.com>
References: <1298039252.6201.66.camel@edumazet-laptop>
 <4D5E8655.5070304@trash.net>
 <20110218145850.GF2939@psychotron.redhat.com>
 <20110218.120656.104048936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62699 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757673Ab1BRUNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 15:13:31 -0500
Content-Disposition: inline
In-Reply-To: <20110218.120656.104048936.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Feb 18, 2011 at 09:06:56PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Fri, 18 Feb 2011 15:58:51 +0100
>
>> Fri, Feb 18, 2011 at 03:46:45PM CET, kaber@trash.net wrote:
>>>Am 18.02.2011 15:27, schrieb Eric Dumazet:
>>>> Le vendredi 18 f=E9vrier 2011 =E0 15:14 +0100, Jiri Pirko a =E9cri=
t :
>>>>=20
>>>>> Do not know how to do it better. As for percpu variable, not only
>>>>> origdev would have to be remembered but also probably skb pointer=
 to
>>>>> know if it's the first run on the skb or not. Can't really figure=
 out a
>>>>> better solution. Can you?
>>>>=20
>>>> I'll try and let you know.
>>>
>>>Why not simply do a lookup on skb->iif?
>>=20
>> Well I was trying to avoid iterating over list of devices for each
>> incoming frame.
>
>It is not list, it is hash :-)

Even if, Do you think that this would be ok?

