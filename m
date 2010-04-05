From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/2] netdev: buffer infrastructure to log network
 driver's information
Date: Mon, 05 Apr 2010 12:31:55 -0700 (PDT)
Message-ID: <20100405.123155.263974951.davem@davemloft.net>
References: <4BB98828.5030302@jp.fujitsu.com>
	<4BB988C9.9070709@jp.fujitsu.com>
	<1270456946.1971.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sanagi.koki@jp.fujitsu.com, netdev@vger.kernel.org,
	izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com,
	nhorman@tuxdriver.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38440
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756097Ab0DETbx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 15:31:53 -0400
In-Reply-To: <1270456946.1971.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Apr 2010 10:42:26 +0200

> Le lundi 05 avril 2010 =E0 15:52 +0900, Koki Sanagi a =E9crit :
>> This patch implements buffer infrastructure under driver/net.
>> This buffer records information from network driver.
>>=20
>> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>> ---
>>   drivers/net/Kconfig     |    8 +
>>   drivers/net/Makefile    |    1 +
>>   drivers/net/ndrvbuf.c   |  535 +++++++++++++++++++++++++++++++++++=
++++++++++++
>>   include/linux/ndrvbuf.h |   57 +++++
>>   4 files changed, 601 insertions(+), 0 deletions(-)
>>=20
>=20
> Wow, 600 lines... thats what I call bloat...

And we have all sorts of facilities for creating filesystem
streams and ring buffers of debug information.

You could even hook into 'perf' to log and process these
events in probably like 12 lines of code.
