From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: export IP6_RT_PRIO_* to userland
Date: Mon, 05 Nov 2012 12:43:05 -0500 (EST)
Message-ID: <20121105.124305.1002288640313724910.davem@davemloft.net>
References: <1352129298-1104-1-git-send-email-nicolas.dichtel@6wind.com>
	<20121105.120017.1189906314924845791.davem@davemloft.net>
	<5097F5DF.7040507@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab2KERnI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 12:43:08 -0500
In-Reply-To: <5097F5DF.7040507@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 05 Nov 2012 18:22:39 +0100

> Le 05/11/2012 18:00, David Miller a =E9crit :
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Mon,  5 Nov 2012 16:28:18 +0100
>>
>>> The kernel uses some default metric when routes are managed. For
>>> example, a
>>> static route added with a metric set to 0 is inserted in the kernel
>>> with
>>> metric 1024 (IP6_RT_PRIO_USER).
>>> It is useful for routing daemons to know these values, to be able t=
o
>>> set routes
>>> without interfering with what the kernel does.
>>>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>
>> But these belong in the libc headers anyways.
>>
>> If we haven't provided them for so long, there's no real value of
>> adding them now.
>>
> But how can a daemon know which default values are used? If it wants
> to add a route with metric =3D default + x, it should first add it wi=
th
> metric =3D 0, check the result and then change the metric.

What do we do on the ipv4 side and how do daemons cope in that situatio=
n?
