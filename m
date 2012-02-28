From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH v2] ARM: LPC32xx: Ethernet driver
Date: Tue, 28 Feb 2012 14:32:49 +0100
Message-ID: <4F4CD781.2090802@antcom.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E83@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: baruch@tkos.co.il, alexander.h.duyck@intel.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	eilong@broadcom.com, Kevin Wells <kevin.wells@nxp.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E83@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 02/28/2012 02:11 PM, David Laight wrote:
>> Thanks for the note! I actually found out that in many cases, the
>> bootloader already initialized the hardware with the target 
>> MAC address so we can use this one.
>>
>> For the case that it _isn't_ initialized already, is it the right
> thing
>> to use a hard coded default MAC address to be replaced by the final
> one
>> in userspace? (I found such examples in some current micrel/ and amd/
> drivers.)
> 
> Using a fixed address is a very bad idea ...

Yes, that's why we previously had a cmdline param for it (but removed it
upon request from the netdev maintainer).

So if the hardware defaults to 00:00:00:00:00:00, what is the
"consistent policy we want to enforce in all drivers"?

A link or hint would be sufficient.

Thanks in advance,

Roland
