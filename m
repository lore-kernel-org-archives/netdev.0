From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 25 Sep 2007 19:55:29 +0200
Message-ID: <46F94B91.5020209@hartkopp.net>
References: <20070925122029.15989.0@janus.isnogud.escape.de>	<20070925122244.15989.5@janus.isnogud.escape.de>	<20070925.222631.116063075.yoshfuji@linux-ipv6.org> <ygfir5yetfp.fsf@janus.isnogud.escape.de> <46F91F64.2050008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	davem@davemloft.net, joe@perches.com, tglx@linutronix.de,
	oliver.hartkopp@volkswagen.de
To: =?ISO-8859-15?Q?YOSHIFUJI_Hideaki_/_=C8=A3=D1=C0?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:19086 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbXIYR4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 13:56:25 -0400
In-Reply-To: <46F91F64.2050008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Urs Thuermann wrote:
>  =20
>> YOSHIFUJI Hideaki / =C8=A3=D1=C0  <yoshfuji@linux-ipv6.org> writes:
>>
>>
>>    =20
>>> I'm not a lawyer, but the following lines:
>>>
>>> | + * Alternatively, provided that this notice is retained in full,=
 this
>>>                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>> | + * software may be distributed under the terms of the GNU Genera=
l
>>> | + * Public License ("GPL") version 2 as distributed in the 'COPYI=
NG'
>>> | + * file from the main directory of the linux kernel source.
>>>
>>> make this whole licence imcompatible with GPL.
>>>      =20
>>    =20

The module license is "Dual BSD/GPL" as many other code in the Linux
Kernel. So this should not be any problem.


>>> I do think you need to allow people to select GPLv2 only.
>>>      =20
>>    =20

The Linux Kernel is currently under GPLv2 and we just wanted to follow
Linus' mind and so we referenced the COPYING file which many other
source does as well. Indeed it was a hard thing to make our code
available under GPL (as creating and publishing open source software is
really no a usual thing for the Volkswagen rights department). So i
discussed with the rights department about several disclaimers inside
the current Kernel (especially the stuff that has been signed off by
companies like IBM, Motorola, etc.). In this process it turned out to b=
e
the best to license the code under "Dual BSD/GPL" as it grants more
rights to the programmer (including ourselves) than a GPL only license.
I assume this was the intention from IBM, Motorola and all the others
also. Btw. inside the Kernel context it behaves exactly like GPL code
(like all the other dual license code).

So i really can't see any problem here. If so there would have been a
big discussion about the other "Dual BSD/GPL" code.

Best regards,
Oliver

ps. I hope, i found the right words right now, as i'm not very familiar
with English :)



