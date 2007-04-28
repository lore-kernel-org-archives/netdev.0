From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 2/3] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Sun, 29 Apr 2007 02:10:37 +0900 (JST)
Message-ID: <20070429.021037.41179188.anemo@mba.ocn.ne.jp>
References: <20070425.015549.108742168.anemo@mba.ocn.ne.jp>
	<20070428010414.2ba43a30.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org, jeff@garzik.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:49477 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812AbXD1RKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 13:10:36 -0400
In-Reply-To: <20070428010414.2ba43a30.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 28 Apr 2007 01:04:14 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> platform_device_register_simple() copies *res by value, so I believe we can
> make res[] static __initdata.  This way we don't need to evaluate the array
> on the stack at runtime, and the data gets discarded after initcalls have
> run.
> 
> Can you please review and test the below?  I had a go but wasn't able to
> fumble my way to a suitable config (I hope):

It looks OK.  I will merge your fix to updated patch.  Thank you.

And the lack of its defconfig should be fixed anyway, but it should be
another story ...

---
Atsushi Nemoto
