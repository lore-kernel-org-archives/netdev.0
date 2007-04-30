From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 2/3] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Tue, 01 May 2007 00:14:26 +0900 (JST)
Message-ID: <20070501.001426.75186152.anemo@mba.ocn.ne.jp>
References: <20070425.015549.108742168.anemo@mba.ocn.ne.jp>
	<20070428010414.2ba43a30.akpm@linux-foundation.org>
	<20070429.021037.41179188.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:54337 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755450AbXD3PO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 11:14:26 -0400
In-Reply-To: <20070429.021037.41179188.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 29 Apr 2007 02:10:37 +0900 (JST), Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> > platform_device_register_simple() copies *res by value, so I believe we can
> > make res[] static __initdata.  This way we don't need to evaluate the array
> > on the stack at runtime, and the data gets discarded after initcalls have
> > run.
> > 
> > Can you please review and test the below?  I had a go but wasn't able to
> > fumble my way to a suitable config (I hope):
> 
> It looks OK.  I will merge your fix to updated patch.  Thank you.

Unfortunately, the RBTX4938 part can not be converted to static
__initdata since RBTX4938_RTL_8019_BASE is not a constant.

And I think the change for toshiba_rbtx4927_rtc_init() should be an
another patch.  So I will add the "static __initdata" only to
rbtx4927_ne_init().

---
Atsushi Nemoto
