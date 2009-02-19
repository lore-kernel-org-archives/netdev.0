From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Thu, 19 Feb 2009 10:20:04 -0800
Message-ID: <15059.1235067604@death.nxdomain.ibm.com>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <20090217095232.5da06b9f@werewolf.home> <200902172001.41804.arvidjaar@mail.ru> <499DA1AB.7040903@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrey Borzenkov <arvidjaar@mail.ru>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	=?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3F=3D22J=3D2EA=3D2E=5FMagall=3F=3D?=
	 =?us-ascii?Q?_=3D=3FISO-8859-1=3FQ=3F=3DF3n=3D22=3F=3D?=
	<jamagallon@ono.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:40645 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbZBSSUM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 13:20:12 -0500
In-reply-to: <499DA1AB.7040903@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Randy Dunlap <randy.dunlap@oracle.com> wrote:

>Andrey Borzenkov wrote:
>> Forward to bonding and netdev
>>=20
>> On 17 of February 2009 11:52:32 J.A. Magall=C3=B3n wrote:
>>> Hi all...
>>>
>>> Don't know if this is specific for -rc5, I have jumped from 28.4 to
>>> 29-rc5. In this latest kernel, I can not install 'bonding' module i=
f
>>> 'ipv6' is disabled to load via modprobe.conf:
>>>
>>> install ipv6 /bin/true
>>>
>>> Trying bonding gives this dmesg:
>>>
>>> bonding: Unknown symbol ndisc_build_skb
>>> bonding: Unknown symbol in6_dev_finish_destroy
>>> bonding: Unknown symbol ndisc_send_skb
>>> bonding: Unknown symbol unregister_inet6addr_notifier
>>> bonding: Unknown symbol register_inet6addr_notifier
>>>
>>> Commenting the line in modprobe.conf makes things smooth again.
>>> We can not disable ipv6 anymore ?
>>>
>>=20
>> If IPv6 is disable in kernel config bonding loads. But I think it is=
=20
>> regression, it should be possible to disable IPv6 if not required.
>
>Just for clarification, is this a run-time (module load-time) error
>but not a build error?

	Yes, module load error, but not a build error.

	The build with CONFIG_IPV6 is fine, and bonding loads fine as
long as ipv6 is loaded.  The issue arises when the ipv6 module is
prevented from loading; in that case, bonding cannot load because it no=
w
requires functionality from ipv6.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
