From: Ingo Kofler <ikofler@edu.uni-klu.ac.at>
Subject: Re: Problems obtaining software TX timestamps
Date: Wed, 08 Sep 2010 23:21:36 +0200
Message-ID: <4C87FE60.7090209@edu.uni-klu.ac.at>
References: <4C877D8A.6040002@edu.uni-klu.ac.at> <1283958771.2748.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailsrv.uni-klu.ac.at ([143.205.180.44]:57475 "EHLO
	mailsrv.uni-klu.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755460Ab0IHVVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:21:44 -0400
In-Reply-To: <1283958771.2748.85.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 09/08/2010 05:12 PM, Eric Dumazet wrote:
> Le mercredi 08 septembre 2010 =C3=A0 14:11 +0200, Ingo Kofler a =C3=A9=
crit :
>   =20
>> Dear all,
>>
>> I am trying to obtain software TX timestamps for a each outgoing pac=
ket
>> of an UDP socket. For that purpose I set the SO_TIMESTAMPING socket
>> option to SOF_TIMESTAMPING_TX_SOFTWARE | SOF_TIMESTAMPING_SOFTWARE. =
The
>> setsockopt call succeeds and also a subsequent getsockopt returns th=
e
>> correct flags. However, if a send a single datagram over the socket =
and
>> try to fetch the packet as well as its timestamp via the socket's
>> MSG_ERRQUEUE I do not get any information. Rather, the select call w=
aits
>> infinitely on the error queue....
>>
>> I hardly found any documentation on this timestamping mechanism exce=
pt
>> the text file in the kernel source code. All I've figured out is tha=
t if
>> I want to have hardware TX timestamps, I'll have to make a further i=
octl
>> which requires root permissions to active the hardware timestamping.=
 But
>> this is not what I want... software timestamps are sufficient for me=
=2E
>>     =20
> To my knowledge, no driver calls skb_tx_timestamp()
>
> You'll need to tweak your NIC driver to play with this TX timestamps
>   =20
Ok, for hardware timestamps it seems logically for me that the driver=20
has to support this. But what about the software timestamps - do they=20
also require support from the driver? Is there no generic implementatio=
n=20
in the networking stack?
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   =20

