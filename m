From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH] net: phy: Add sysfs attribute to prevent PHY suspend
Date: Mon, 10 Mar 2014 01:53:33 +0100
Message-ID: <531D0D0D.4050703@gmail.com>
References: <531CF864.9040406@gmail.com> <20140309.203001.1318893833441564547.davem@davemloft.net> <531D094C.1090205@gmail.com> <20140309.204101.47552917508273123.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, andrew@lunn.ch, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140309.204101.47552917508273123.davem@davemloft.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2014 01:41 AM, David Miller wrote:
> From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Date: Mon, 10 Mar 2014 01:37:32 +0100
>
>> The mechanism is manual, no automatic way to determine it.
>
> We recognize BIOS and ACPI bugs and work around them, by looking at
> version information and whatnot, so you really can't convince me that
> something similar can't be done here perhaps in the platform code.

Hmm, if the is a way to determine the version of that particual u-boot
I'd be happy to exploit that information. But I honestly doubt that.
Compared to u-boot bootloader and kernel interaction, BIOS and ACPI
are well-defined protocols.

I personally, would prefer everybody should update his broken
bootloaders, but that will just not happen.

Anyway, at least for the two boards in question, we know a bootloader
workaround. The version does support user commands to re-enable the PHY
by writing the corresponding registers.

Unfortunately, the is a bug in phy_ethtool_get_wol that up to now,
prevents most PHYs (without .wol callbacks) from being suspended.
I wanted to get in a way to disable suspend before sending a fix.

If you are that against a sysfs knob, I guess, we will just see how
many more bootloaders are broken and some will not have a way to write
PHY registers.

Sebastian
