From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dt: bindings: Add a generic ethernet device binding
Date: Sat, 16 Jul 2016 18:02:45 -0700 (PDT)
Message-ID: <20160716.180245.1523267216987842392.davem@davemloft.net>
References: <47a052a1-cc8b-0f75-e44a-450c4a0ac075@redhat.com>
	<20160715.105158.2028840258568316933.davem@davemloft.net>
	<888927c4-0987-ccfb-e2de-d03f6d4ab319@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
	maxime.ripard@free-electrons.com, wens@csie.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org
To: hdegoede@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbcGQBCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 21:02:49 -0400
In-Reply-To: <888927c4-0987-ccfb-e2de-d03f6d4ab319@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans de Goede <hdegoede@redhat.com>
Date: Sat, 16 Jul 2016 12:12:37 +0200

> Hi,
> 
> On 15-07-16 19:51, David Miller wrote:
>> From: Hans de Goede <hdegoede@redhat.com>
>> Date: Fri, 15 Jul 2016 08:40:00 +0200
>>
>>> Hi,
>>>
>>> On 15-07-16 01:17, David Miller wrote:
>>>> From: Hans de Goede <hdegoede@redhat.com>
>>>> Date: Wed, 13 Jul 2016 12:20:04 +0200
>>>>
>>>>> On some boards (android tablets) different batches use different sdio
>>>>> wifi modules. This is not a problem since sdio is a discoverable bus,
>>>>> so we only need to describe and activate the mmc controller in dt and
>>>>> then the kernel will automatically load the right driver.
>>>>>
>>>>> But sometimes it is useful to specify certain ethernet properties for
>>>>> these "unknown" sdio devices, specifically we want the boot-loader
>>>>> to be able to set "local-mac-address" as some of these sdio wifi
>>>>> modules come without an eeprom / without a factory programmed mac
>>>>> address.
>>>>>
>>>>> Since the exact device is unknown (differs per batch) we cannot use
>>>>> a wifi-chip specific compatible. This commit adds a new
>>>>> "generic,ethernet" binding for use in dt-nodes describing such an
>>>>> unknown ethernet device.
>>>>>
>>>>> Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
>>>>> Signed-off-by: Hans de Goede <hdegoede@redhat.com>
>>>>
>>>> Precedence exists for a "system ethernet address" as far back as the
>>>> original sparc device tree implementation, so please just specify it
>>>> that way rather than trying to force having to make an alias or
>>>> reference to it from a specific device.
>>>
>>> Some boards where this is applicable have both a wired and a wireless
>>> ethernet, so one global setting will not work.
>>
>> Then call it "eth:local-mac-address" and "wifi:local-mac-address"
> 
> Until we get a board with 2 ethernet interfaces, really the alias
> thing
> is working fine here, that is not the problem.

Fair enough.
