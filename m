From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Mon, 10 Jul 2006 20:51:58 +0200
Message-ID: <1152557518.4874.79.camel@laptopd505.fenrus.org>
References: <20060710152032.GA8540@elf.ucw.cz> <44B2940A.2080102@pobox.com>
	 <44B29C8A.8090405@intel.com> <20060710.114717.44959528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, jgarzik@pobox.com, pavel@ucw.cz,
	yi.zhu@intel.com, jketreno@linux.intel.com, netdev@vger.kernel.org,
	linville@tuxdriver.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36834 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1422665AbWGJSwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 14:52:08 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060710.114717.44959528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-10 at 11:47 -0700, David Miller wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> Date: Mon, 10 Jul 2006 11:29:30 -0700
> 
> > Jeff Garzik wrote:
> > > Pavel Machek wrote:
> > >> Kconfig currently allows compiling IPW_2100 and IPW_2200 into kernel
> > >> (not as a module). Unfortunately, such configuration does not work,
> > >> because these drivers need a firmware, and it can't be loaded by
> > >> userspace loader when userspace is not running.
> > > 
> > > False, initramfs...
> > 
> > which would warrant some extra documentation in Kconfig explaining that this 
> > driver needs initramfs with firmware for it to work when compiled in the 
> > kernel. A link to the ipw2x00 documentation might also help.
> 
> Besides, the initramfs runs long after the driver init routine
> runs which is when the firmware needs to be available.

.. unless you use sysfs to do a fake hotunplug + replug the device, at
which point the driver init routine runs again.


