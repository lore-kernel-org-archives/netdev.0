From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v2] isdn: Mark build for telespci and hfc_pci as broken
 for big endian ARM
Date: Sun, 05 Jan 2014 20:25:41 -0800
Message-ID: <52CA3045.80807@roeck-us.net>
References: <1388951367-7411-1-git-send-email-linux@roeck-us.net> <20140105.203959.962622308205839285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.active-venture.com ([67.228.131.205]:61087 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbaAFEZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 23:25:41 -0500
In-Reply-To: <20140105.203959.962622308205839285.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2014 05:39 PM, David Miller wrote:
> From: Guenter Roeck <linux@roeck-us.net>
> Date: Sun,  5 Jan 2014 11:49:27 -0800
>
>> With arm:allmodconfig, building the Teles PCI driver fails with
>>
>> telespci.c:294:2: error: #error "not running on big endian machines now"
>>
>> Similar, building the driver for HFC PCI-Bus cards fails with
>>
>> hfc_pci.c:1647:2: error: #error "not running on big endian machines now"
>>
>> Mark build as broken for big endian ARM machines.
>>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>
> Let's not start getting into the habit of doing this, please.
>
> The reason this isn't easy to do generically from Kconfig is
> probably because it almost never makes any sense to do so.
>
> In fact, if you look at telespci.c there are no DMA descriptors,
> everything is read using MMIO acccesses via the chips FIFO.  There
> really can't be any endianness problems that I see.
>
> Please just remove the CPP checks, that's the best fix.
>

Both drivers build with arm:allmodconfig if I remove the check,
so I am fine with that. I'll send an updated patch.

Thanks,
Guenter
