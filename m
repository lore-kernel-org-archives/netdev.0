From: Jeff Garzik <jgarzik@pobox.com>
Subject: r8169 and tg3
Date: Mon, 17 Nov 2003 23:39:19 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB9A277.70309@pobox.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brad House <brad_mssw@gentoo.org>
In-Reply-To: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Brad House wrote:
> The current in-kernel version of the r8169 driver is v1.2
> from RealTek.  This is a patch against 2.6.0-test9-bk6
> and later kernels that updates the driver to 1.6 from RealTek.
> Just small patches applied to it to port to 2.6 kernel, etc.
> It works with the 8110S chip found on many motherboards,
> especially x86_64 mobos.


A bit of history...   SiS sent me a driver for their gigabit chip, 
SIS190 (sis190.c).  Full of PCI DMA bugs, alignment problems, and fun 
like that.  After taking flak for merging it :) I fixed all those bugs. 
  Fast forward a bit, I find out that sis190.c was copied from r8169.c, 
and modified a bit to work with SiS chips.  I look at r8169.c, and find 
all those same bugs -- and the RealTek updates don't address any of that.

So, what needs to happen is somebody needs to look at the sis190 changes 
that went in, and apply those same fixes to r8169.

Two tangents, while I have your attention:

1) If you have problems with the tg3 driver, we need to get those bug 
reports and fix them.  bcm5700 is not going to be merged into the 
kernel.  Further, there was at least one serious x86-64 issue that was 
fixed in tg3, and we need to make sure users are testing that driver, 
not a non-standard driver with bugs of its own.

2) Please CC me on all net driver patches, since I am the dude that 
actually puts those patches into the kernel.

Thanks,

	Jeff
