From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Add sysfs attribute to prevent PHY suspend
Date: Sun, 09 Mar 2014 23:40:32 -0400 (EDT)
Message-ID: <20140309.234032.873557698878535571.davem@davemloft.net>
References: <531D094C.1090205@gmail.com>
	<20140309.204101.47552917508273123.davem@davemloft.net>
	<531D0D0D.4050703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, andrew@lunn.ch, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <531D0D0D.4050703@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Mon, 10 Mar 2014 01:53:33 +0100

> On 03/10/2014 01:41 AM, David Miller wrote:
>> From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
>> Date: Mon, 10 Mar 2014 01:37:32 +0100
>>
>>> The mechanism is manual, no automatic way to determine it.
>>
>> We recognize BIOS and ACPI bugs and work around them, by looking at
>> version information and whatnot, so you really can't convince me that
>> something similar can't be done here perhaps in the platform code.
> 
> Hmm, if the is a way to determine the version of that particual u-boot
> I'd be happy to exploit that information. But I honestly doubt that.
> Compared to u-boot bootloader and kernel interaction, BIOS and ACPI
> are well-defined protocols.
> 
> I personally, would prefer everybody should update his broken
> bootloaders, but that will just not happen.

What you can do is have a test that _perhaps_ covers a "broader than
reality" list of broken bootloader cases.

Then you have something the bootloader can provide which indicates
that it has been fixed.
