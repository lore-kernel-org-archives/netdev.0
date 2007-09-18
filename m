From: David Miller <davem@davemloft.net>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 12:20:34 -0700 (PDT)
Message-ID: <20070918.122034.83625273.davem@davemloft.net>
References: <1190141114.9540.216.camel@dell>
	<20070918.112337.74737433.davem@davemloft.net>
	<46F01BDE.6020902@zytor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hpa@zytor.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758626AbXIRTVo@vger.kernel.org>
In-Reply-To: <46F01BDE.6020902@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 18 Sep 2007 11:41:34 -0700

> David Miller wrote:
> > 
> > I don't like it because it means people have to setup full initrd's
> > in order to do network booting with such network cards.
> > 
> 
> klibc could help with that, if there is interest in exploring that
> avenue again.

I appreciate the effort you put into klibc and the offer to
make initrd's easier to build.

But the point is that the initrd shouldn't be necessary in the first
place.  There becomes zero point in building these drivers statically
into the kernel, which many of us do specifically to avoid module
loading, initrds, and all that fuss.  Because the driver is totally
crippled even though it's been fully built into the main kernel image.

I mean, it's so incredibly stupid and makes kernel development that
much more difficult.

Every new dependency, be it requiring initrd or something else,
is one more barrier added to kernel development.

I really pine for the days where everything was so simple, and initrd
and modules were the odd ball cases, most developers built everything
into their kernel image.
