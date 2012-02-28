From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH v2] ARM: LPC32xx: Ethernet driver
Date: Tue, 28 Feb 2012 14:08:40 +0100
Message-ID: <4F4CD1D8.8030102@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, eilong@broadcom.com,
	Kevin Wells <kevin.wells@nxp.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: baruch@tkos.co.il
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 2012-02-26 03:28 +100, David Miller wrote:
>> Please use a module_param() instead of a top level kernel parameter.
>
> Actually, remove this entirely, we don't add module parameters
> to force the ethernet address. That should be done in userland
> in some fashion.
>
> We've had many discussions about this recently, and this is the
> consistent policy we want to enforce in all drivers from now on.

Thanks for the note! I actually found out that in many cases, the
bootloader already initialized the hardware with the target MAC address
so we can use this one.

For the case that it _isn't_ initialized already, is it the right thing
to use a hard coded default MAC address to be replaced by the final one
in userspace? (I found such examples in some current micrel/ and amd/
drivers.)

Thanks in advance,

Roland
