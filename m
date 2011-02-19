From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 19 Feb 2011 09:58:17 +0100
Message-ID: <20110219085816.GC2782@psychotron.redhat.com>
References: <1298039252.6201.66.camel@edumazet-laptop>
 <4D5E8655.5070304@trash.net>
 <20110218145850.GF2939@psychotron.redhat.com>
 <20110218.120656.104048936.davem@davemloft.net>
 <20110218205832.GE2602@psychotron.redhat.com>
 <21593.1298070371@death>
 <20110219080523.GB2782@psychotron.redhat.com>
 <1298104675.8559.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62130 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478Ab1BSI6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Feb 2011 03:58:33 -0500
Content-Disposition: inline
In-Reply-To: <1298104675.8559.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 19, 2011 at 09:37:55AM CET, eric.dumazet@gmail.com wrote:
>Le samedi 19 f=E9vrier 2011 =E0 09:05 +0100, Jiri Pirko a =E9crit :
>> This patch converts bonding to use rx_handler. Results in cleaner
>> __netif_receive_skb() with much less exceptions needed. Also
>> bond-specific work is moved into bond code.
>>=20
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>=20
>> v1->v2:
>>         using skb_iif instead of new input_dev to remember original
>> 	device
>> v2->v3:
>> 	set orig_dev =3D skb->dev if skb_iif is set
>>=20
>
>Seems much better ;)
>
>Do you have some performance numbers ?

I don't. I can surely obtain some. What's the best way to measure this?

>
>
>
