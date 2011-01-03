From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: remove meaningless
 /sys/module/bonding/parameters entries.
Date: Mon, 03 Jan 2011 20:59:37 +0100
Message-ID: <4D222AA9.3060109@free.fr>
References: <1293978915-29674-1-git-send-email-nicolas.2p.debian@free.fr> <20110103.113212.260088613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:43932 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932160Ab1ACT7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 14:59:46 -0500
In-Reply-To: <20110103.113212.260088613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/01/2011 20:32, David Miller a =E9crit :
> From: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
> Date: Sun,  2 Jan 2011 15:35:15 +0100
>
>> Only two bonding parameters are exposed in /sys/module/bonding:
>>
>> num_grat_arp
>> num_unsol_na
>>
>> Those values are not module global, but per device.
>>
>> The per device values are available in /sys/class/net/<device>/bondi=
ng.
>>
>> The values exposed in /sys/module/bonding are those given at module =
load time
>> and only used as default values when creating a device. They are rea=
d-only and
>> cannot change in any way.
>>
>> As such, they are mostly meaningless.
>
> First, you forgot to provide a proper "Signed-off-by: " line in your
> patch submission, please read Documentation/SubmittingPatches

Oups, you are right. I forgot it.

> Secondly, you can't remove these, people might be using them.  It
> could be useful, for example, to debug problems with passing module
> parameters in.  This is the one way to find out what actually got
> passed to the module when it loaded.

I perfectly understand this.

The bonding module supports 19 different parameters, but only two are e=
xposed into=20
/sys/modules/bonding. Also, only one of those parameters is global to t=
he module (max_bonds). All=20
other parameters are in fact per device and exposed (read and write if =
appropriate) in=20
/sys/class/net/<device>/bonding.

As there is no good reason to have only those two parameters exposed in=
to /sys/modules/bonding, we=20
should remove them or add all the other one. Due to the lack of real gl=
obal meaning for those two, I=20
thought removing them was the right option.

> Therefore I'm not applying this patch, sorry.

Anyway, thanks.

	Nicolas.
