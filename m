From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 12:27:04 -0700
Message-ID: <46F02688.8030507@zytor.com>
References: <1190141114.9540.216.camel@dell>	<20070918.112337.74737433.davem@davemloft.net>	<46F01BDE.6020902@zytor.com> <20070918.122034.83625273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:49144 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365AbXIRT1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 15:27:15 -0400
In-Reply-To: <20070918.122034.83625273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "H. Peter Anvin" <hpa@zytor.com>
> Date: Tue, 18 Sep 2007 11:41:34 -0700
> 
>> David Miller wrote:
>>> I don't like it because it means people have to setup full initrd's
>>> in order to do network booting with such network cards.
>>>
>> klibc could help with that, if there is interest in exploring that
>> avenue again.
> 
> I appreciate the effort you put into klibc and the offer to
> make initrd's easier to build.
>
> But the point is that the initrd shouldn't be necessary in the first
> place.  There becomes zero point in building these drivers statically
> into the kernel, which many of us do specifically to avoid module
> loading, initrds, and all that fuss.  Because the driver is totally
> crippled even though it's been fully built into the main kernel image.
> 
> I mean, it's so incredibly stupid and makes kernel development that
> much more difficult.
> 
> Every new dependency, be it requiring initrd or something else,
> is one more barrier added to kernel development.
> 
> I really pine for the days where everything was so simple, and initrd
> and modules were the odd ball cases, most developers built everything
> into their kernel image.

Well, what I was referring to here, of course, was the initramfs
integrated in the kernel image, so it all comes out of the kernel build
tree and produces a single bootable image.  The fact that part of it
contains userspace code is in that way invisible.

That was kind of the point here, and the only reason for pushing klibc
into the kernel build tree at all.  Under the "distros use external
initrd anyway" school of thought, whatever libc used for that can be
external anyway.

	-hpa
