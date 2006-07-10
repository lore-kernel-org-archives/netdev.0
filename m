From: David Miller <davem@davemloft.net>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Mon, 10 Jul 2006 11:47:17 -0700 (PDT)
Message-ID: <20060710.114717.44959528.davem@davemloft.net>
References: <20060710152032.GA8540@elf.ucw.cz>
	<44B2940A.2080102@pobox.com>
	<44B29C8A.8090405@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, pavel@ucw.cz, yi.zhu@intel.com,
	jketreno@linux.intel.com, netdev@vger.kernel.org,
	linville@tuxdriver.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51920
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422762AbWGJSqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 14:46:36 -0400
To: auke-jan.h.kok@intel.com
In-Reply-To: <44B29C8A.8090405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Mon, 10 Jul 2006 11:29:30 -0700

> Jeff Garzik wrote:
> > Pavel Machek wrote:
> >> Kconfig currently allows compiling IPW_2100 and IPW_2200 into kernel
> >> (not as a module). Unfortunately, such configuration does not work,
> >> because these drivers need a firmware, and it can't be loaded by
> >> userspace loader when userspace is not running.
> > 
> > False, initramfs...
> 
> which would warrant some extra documentation in Kconfig explaining that this 
> driver needs initramfs with firmware for it to work when compiled in the 
> kernel. A link to the ipw2x00 documentation might also help.

Besides, the initramfs runs long after the driver init routine
runs which is when the firmware needs to be available.
