From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Mon, 10 Jul 2006 23:05:06 +0200
Message-ID: <200607102305.06572.mb@bu3sch.de>
References: <20060710152032.GA8540@elf.ucw.cz> <44B2940A.2080102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, jketreno@linux.intel.com,
	Netdev list <netdev@vger.kernel.org>, linville@tuxdriver.com,
	kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:14005
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1422919AbWGJVDT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 17:03:19 -0400
To: Jeff Garzik <jgarzik@pobox.com>, Pavel Machek <pavel@ucw.cz>
In-Reply-To: <44B2940A.2080102@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 July 2006 19:53, you wrote:
> Pavel Machek wrote:
> > Kconfig currently allows compiling IPW_2100 and IPW_2200 into kernel
> > (not as a module). Unfortunately, such configuration does not work,
> > because these drivers need a firmware, and it can't be loaded by
> > userspace loader when userspace is not running.
> 
> False, initramfs...

Does the ipw driver _really_ need the firmware on insmod time?
bcm43xx, for example, loads the firmware on "ifconfig up" time.
If ipw really needs the firmware on insmod, is it possible to
defer it to later at "ifconfig up" time?

-- 
Greetings Michael.
