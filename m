From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 08/14] pktgen: reorganize transmit loop
Date: Wed, 02 Sep 2009 15:06:04 +0200
Message-ID: <4A9E6DBC.5030904@trash.net>
References: <20090827235705.740919364@vyatta.com>	<4A975480.3080507@candelatech.com>	<20090827224902.49f80920@nehalam>	<20090828.230428.211927371.davem@davemloft.net> <20090901143033.0e9cb7ec@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, greearb@candelatech.com,
	robert.olsson@its.uu.se, netdev@vger.kernel.org, tglx@linutronix.de
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46010 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbZIBNGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 09:06:24 -0400
In-Reply-To: <20090901143033.0e9cb7ec@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 28 Aug 2009 23:04:28 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> I think Patrick's goals are quite sound, and with his patch we
>> could let pktgen transmit over vlan just like any other device.
>>
>> Otherwise we give no way to use pktgen to test the VLAN transmit path.
> 
> The only valid returns from device are OK, BUSY, or LOCKED
> anything else is an error and should never occur.
> 
> If the vlan code returns other values, it must translate.

That was part of my patches to allow hard_start_xmit() to return
NETDEV_TX codes, NET_XMIT codes to propagate transmission qdisc state
upwards through virtual devices, as well as errno codes to propagate
errors from virtual devices, like EHOSTUNREACH from an IP tunnel device.

I'll refresh that patch and will post it tonight or tommorrow.

