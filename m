From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Mon, 10 Jul 2006 11:29:30 -0700
Message-ID: <44B29C8A.8090405@intel.com>
References: <20060710152032.GA8540@elf.ucw.cz> <44B2940A.2080102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, yi.zhu@intel.com,
	jketreno@linux.intel.com, Netdev list <netdev@vger.kernel.org>,
	linville@tuxdriver.com, kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7759 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1422644AbWGJSeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 14:34:11 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44B2940A.2080102@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Pavel Machek wrote:
>> Kconfig currently allows compiling IPW_2100 and IPW_2200 into kernel
>> (not as a module). Unfortunately, such configuration does not work,
>> because these drivers need a firmware, and it can't be loaded by
>> userspace loader when userspace is not running.
> 
> False, initramfs...

which would warrant some extra documentation in Kconfig explaining that this 
driver needs initramfs with firmware for it to work when compiled in the 
kernel. A link to the ipw2x00 documentation might also help.

Cheers,

Auke
