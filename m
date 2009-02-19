From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Thu, 19 Feb 2009 10:15:07 -0800
Message-ID: <499DA1AB.7040903@oracle.com>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <20090217095232.5da06b9f@werewolf.home> <200902172001.41804.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	=?ISO-8859-1?Q?=22J=2EA=2E_Magall?= =?ISO-8859-1?Q?=F3n=22?=
	<jamagallon@ono.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andrey Borzenkov <arvidjaar@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:32044 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791AbZBSSOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 13:14:53 -0500
In-Reply-To: <200902172001.41804.arvidjaar@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey Borzenkov wrote:
> Forward to bonding and netdev
>=20
> On 17 of February 2009 11:52:32 J.A. Magall=F3n wrote:
>> Hi all...
>>
>> Don't know if this is specific for -rc5, I have jumped from 28.4 to
>> 29-rc5. In this latest kernel, I can not install 'bonding' module if
>> 'ipv6' is disabled to load via modprobe.conf:
>>
>> install ipv6 /bin/true
>>
>> Trying bonding gives this dmesg:
>>
>> bonding: Unknown symbol ndisc_build_skb
>> bonding: Unknown symbol in6_dev_finish_destroy
>> bonding: Unknown symbol ndisc_send_skb
>> bonding: Unknown symbol unregister_inet6addr_notifier
>> bonding: Unknown symbol register_inet6addr_notifier
>>
>> Commenting the line in modprobe.conf makes things smooth again.
>> We can not disable ipv6 anymore ?
>>
>=20
> If IPv6 is disable in kernel config bonding loads. But I think it is=20
> regression, it should be possible to disable IPv6 if not required.

Just for clarification, is this a run-time (module load-time) error
but not a build error?

--=20
~Randy
