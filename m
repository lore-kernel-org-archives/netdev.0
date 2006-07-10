From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Mon, 10 Jul 2006 13:53:14 -0400
Message-ID: <44B2940A.2080102@pobox.com>
References: <20060710152032.GA8540@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, jketreno@linux.intel.com,
	Netdev list <netdev@vger.kernel.org>, linville@tuxdriver.com,
	kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43488 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1422720AbWGJRx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 13:53:27 -0400
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20060710152032.GA8540@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek wrote:
> Kconfig currently allows compiling IPW_2100 and IPW_2200 into kernel
> (not as a module). Unfortunately, such configuration does not work,
> because these drivers need a firmware, and it can't be loaded by
> userspace loader when userspace is not running.

False, initramfs...


