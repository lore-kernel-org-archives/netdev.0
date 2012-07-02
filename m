From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: AW: AW: RFC: replace packets already in queue
Date: Mon, 02 Jul 2012 22:32:23 +0200
Message-ID: <4FF20557.4090501@gmail.com>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>  <4FEC854E.8080603@hp.com>  <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>  <1340960817.15719.6.camel@edumazet-glaptop>  <FB112703C4930F4ABEBB5B763F964911393795D6@MAILSERV2A.lorien.fkie.fgan.de> <1341214310.5269.27.camel@edumazet-glaptop> <FB112703C4930F4ABEBB5B763F96491139379643@MAILSERV2A.lorien.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55551 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab2GBUbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 16:31:21 -0400
Received: by eeit10 with SMTP id t10so2231796eei.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 13:31:20 -0700 (PDT)
In-Reply-To: <FB112703C4930F4ABEBB5B763F96491139379643@MAILSERV2A.lorien.fkie.fgan.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/07/2012 10:38, Erdt, Ralph a =C3=A9crit :
>>> Even if the wireless queue is a problem (because of our setup, this
>> is
>>> not a problem), the network stack queue (*) is the biggest queue, a=
nd
>>> a good point to optimize.
>>
>> Hmm, I am not convinced you have no queues on wireless.
>>
>> Please describe how you managed this.
>>
>> In fact this is the biggest problem with wireless : mac82011 framewo=
rk
>> aggressively pull packets from Linux packet qdisc in order to perfor=
m
>> packet aggregation.
>
> I did not talking about W-LAN (802.11). I'm talking about an property=
 technology which is able to
> send over KILOMETERs (WLAN<  100m) but with VERY low bandwidth: 9600 =
bit (no Mega, Giga or Kilo!)
> (W-LAN: slowest: 1Mbit). The devices is loosely connected to our boxe=
s: No linux driver but a
> program which create an virtual network device. This just sends one p=
acket to the devices and
> then waits for the acknowledgement that the packet was sent. THEN the=
 next packet will be send.
> There is no further queue, because the wireless is so lame, that ther=
e is no need for that! (BTW:
> the qdisc and the connector are distinct problems/programs. There is =
no dependency.)

If I were you, I would use a tun/tap interface and manage a private pac=
ket queue in userspace. This=20
way, you wouldn't have to manage the overhead of porting your kernel co=
de to every new kernel versions.

	Nicolas.
