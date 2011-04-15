From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: The bonding driver should notify userspace of MAC address change
Date: Fri, 15 Apr 2011 12:22:48 -0700
Message-ID: <11492.1302895368@death>
References: <20110415184407.550abd88@pomiocik.lan> <4DA89114.9040900@gmail.com> <10227.1302893590@death> <20110415191249.GA6879@linuxace.com>
Cc: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>,
	=?us-ascii?B?PT9VVEYtOD9CP1RXbGphR0hGZ2lCSHc3Tnlibms9Pz0=?=
	<mgorny@gentoo.org>, netdev@vger.kernel.org, roy@marples.name,
	Andy Gospodarek <andy@greyhouse.net>
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:34061 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756715Ab1DOTWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 15:22:54 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3FJK7Vk012060
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 13:20:07 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3FJMpsi117720
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 13:22:51 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3FJMoIe008693
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 13:22:51 -0600
In-reply-to: <20110415191249.GA6879@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Oester <kernel@linuxace.com> wrote:

>On Fri, Apr 15, 2011 at 11:53:10AM -0700, Jay Vosburgh wrote:
>> >A bonding device should not report link up to userspace until at least one slave is present and up.
>> >
>> >And possibly, a bonding device should report link down if all slaves are down or all slave were removed.
>> >
>> >Jay, Andy, does this sounds sensible to you?
>> 
>> 	I was just reading their bug and doing an experiment; I don't
>> see that bonding reports carrier up until there's at least one slave
>> (even if it's configured up), e.g.,
>> 
>
>This was only recently fixed - see e826eafa65c6f1f7c8db5a237556cebac57ebcc5
>(bonding: Call netif_carrier_off after register_netdevice). Perhaps the
>reporter is not using a recent kernel?

	Yah, I looked that up after I'd sent my prior email.  Since that
change went in only a month ago, maybe they don't have it.

	On the other hand, I did my test on a FC 14 kernel,
2.6.35.6-45.fc14, which claims to have been built in October 2010, and
it seemed to behave properly.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
