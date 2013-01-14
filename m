From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem
 platform
Date: Mon, 14 Jan 2013 13:34:12 -0500 (EST)
Message-ID: <20130114.133412.479351928049237212.davem@davemloft.net>
References: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com>
	<20130112.153533.1713284383322153346.davem@davemloft.net>
	<1358183953.1713.28.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cpuwolf@gmail.com, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com, bjorn@mork.no,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756935Ab3ANSeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 13:34:17 -0500
In-Reply-To: <1358183953.1713.28.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Mon, 14 Jan 2013 11:19:13 -0600

> On Sat, 2013-01-12 at 15:35 -0800, David Miller wrote:
>> From: Wei Shuai <cpuwolf@gmail.com>
>> Date: Sat, 12 Jan 2013 19:34:39 +0800
>> 
>> > Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. so I
>> > introduce a flag CDC_NCM_DRIVER_DATA_NOARP which is defined in
>> > driver_info:data. so later on, if more such buggy devices are found,
>> > they could use same flag to handle.
>> 
>> Is it no able to do ARP or, the more likely case, does broadcast
>> not work at all?
>> 
>> If it's the latter, IFF_NOARP is just making over the real problem.
>> 
>> I'm not applying this, no hardware device should set IFF_NOARP.
>> You probably really want IFF_POINTOPOINT or similar.
> 
> IFF_NOARP is already done for other WWAN devices (sierra_net, hso,
> cdc-ether, cdc-phonet, lg-vl600, etc) so there is some precedent.  Some
> drivers (phonet, hso) set *both* POINTTOPOINT and NOARP.  Is that
> redundant, and should all WWAN drivers be moved to only POINTTOPOINT?
> 
> (aside: usbnet has FLAG_POINTTOPOINT, but that's nothing to do with
> IFF_POINTTOPOINT, it only controls whether the interface is named usbX
> or ethX.  Confusing.)

I can't answer any of your questions unless you tell me what the
real limitation of these devices is.

For the second time, is the problem that these devices cannot
support broadcast packets properly?
