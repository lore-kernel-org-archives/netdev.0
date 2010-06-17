From: Einar EL Lueck <ELELUECK@de.ibm.com>
Subject: RE: ipv6: netif_carrier_(on|off) with traces afterwards
Date: Thu, 17 Jun 2010 16:50:05 +0200
Message-ID: <OFD4E8B395.2268B8B1-ONC1257745.00516577-C1257745.00517D27@de.ibm.com>
References: <OF3A036420.64516D4F-ONC1257744.00492A34-C1257744.004A240B@de.ibm.com> <EA929A9653AAE14F841771FB1DE5A1365FF43AB7B9@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NetDev <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:45174 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760185Ab0FQOuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 10:50:08 -0400
Received: from d12nrmr1707.megacenter.de.ibm.com (d12nrmr1707.megacenter.de.ibm.com [9.149.167.81])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id o5HEo757032273
	for <netdev@vger.kernel.org>; Thu, 17 Jun 2010 14:50:07 GMT
Received: from d12av05.megacenter.de.ibm.com (d12av05.megacenter.de.ibm.com [9.149.165.216])
	by d12nrmr1707.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5HEo72H1589420
	for <netdev@vger.kernel.org>; Thu, 17 Jun 2010 16:50:07 +0200
Received: from d12av05.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av05.megacenter.de.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5HEo63n007784
	for <netdev@vger.kernel.org>; Thu, 17 Jun 2010 16:50:06 +0200
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FF43AB7B9@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Tantilov, Emil S" <emil.s.tantilov@intel.com> wrote on 06/16/2010 05:55:45
PM:

> From:
>
> "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>
> To:
>
> Einar EL Lueck/Germany/IBM@IBMDE
>
> Cc:
>
> NetDev <netdev@vger.kernel.org>
>
> Date:
>
> 06/16/2010 05:55 PM
>
> Subject:
>
> RE: ipv6: netif_carrier_(on|off) with traces afterwards
>
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On
> >Behalf Of Einar EL Lueck
> >Sent: Wednesday, June 16, 2010 6:30 AM
> >To: netdev@vger.kernel.org
> >Subject: ipv6: netif_carrier_(on|off) with traces afterwards
> >
> >
> >Hi,
> >With IPv6 addresses configured and and a network card doing
> >netif_carrier_off|on we see afterwards in 2.6.34 on S/390 some traces in
> >fib.
> >
> >Example sequence of operations:
> >ip -6 addr add fd00:10:30:49:4008:ffff:35:2/80 dev eth1
> >ip link set eth1 up
> >ip link set eth1 down
> ># the following lines have as effect netif_carrier_off and then on
(among
> >other stuff)
> >echo 0 > /sys/bus/ccwgroup/drivers/qeth/devices/0.0.e300/online
> >echo 1 > /sys/bus/ccwgroup/drivers/qeth/devices/0.0.e300/online
> ># end of plugging
> >ip link set eth1  up
> >ip link set eth1 down
> >=> at this point we get the following trace:
> >
> >Badness
> >at /home/autobuild/BUILD/linux-2.6.34-20100531/net/ipv6/ip6_fib.c:1160
>
> <snip>
>
> >
> >Has anybody seen effects like this before on other platforms, or has
> >anybody suggestions for the root cause?
>
> I had similar issues. The following patches fixed it for me:
>
> http://marc.info/?l=linux-netdev&m=127472600330413
>
> http://marc.info/?l=linux-netdev&m=127472599530407
>
> Thanks,
> Emil
>

Fixed it for me, too.
Thanks,
Einar.

