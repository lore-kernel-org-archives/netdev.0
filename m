From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Wed, 27 Jul 2016 09:39:41 +0300
Message-ID: <87popz8tzm.fsf@purkki.adurom.net>
References: <201607260457.u6Q4v3pM010082@sdf.org>
	<2589898.190WVraD7Z@debian64>
	<66636d159da5342b1387035fbcfe0d35@triadic.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Lamparter <chunkeey@googlemail.com>,
	Alan Curry <rlwinm@sdf.org>, Al Viro <viro@zeniv.linux.org.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alexmcwhirter@triadic.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59660 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcG0Gjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 02:39:46 -0400
In-Reply-To: <66636d159da5342b1387035fbcfe0d35@triadic.us>
	(alexmcwhirter@triadic.us's message of "Tue, 26 Jul 2016 14:15:55
	-0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alexmcwhirter@triadic.us writes:

> On 2016-07-26 09:59, Christian Lamparter wrote:
>> Thanks, I gave the program a try with my WNDA3100 and a WN821N v2
>> devices.
>> I did not see any corruptions in any of the tests though. Can you
>> tell me
>> something about your wireless network too? I would like to know what
>> router
>> and firmware are you using? Also important: what's your wireless
>> configuration?
>> (WPA?, CCMP or TKIP? HT40, HT20 or Legacy rates? ...)
>>
>> Probably the quickest and easiest way to get that information is by
>> running
>> the following commands as root, when you are connected to your wifi
>> network
>> and post the results:
>> # iw dev wlan0 link
>> # iw dev wlan0 scan dump
>>
>> (You can of course remove your device's MACs, but please do it
>> consistently).
>>
>> Regards,
>> Christian
>
> I wonder if this is something that is only affecting certain NIC's?
> For example, it see this issue on sun4u boxes with tigon3 and hme
> interfaces. But on my sun4v boxes that have e1000 interfaces
> everything works fine.

Kernel configuration might also make a difference. Trying to find an
Kconfig option which affects this could be useful.

-- 
Kalle Valo
