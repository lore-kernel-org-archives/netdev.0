From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert e100 driver to request_firmware()
Date: Sun, 15 Jun 2008 19:42:05 +0100
Message-ID: <1213555326.26255.518.camel@pmac.infradead.org>
References: <1213522966.26255.433.camel@pmac.infradead.org>
	 <48555677.7040209@garzik.org>
	 <3f9a31f40806151134n1b5e4de7m2ccd9c8a9e98cdb4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Auke Kok <auke-jan.h.kok@intel.com>
To: Jaswinder Singh <jaswinderlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38249 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192AbYFOSmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 14:42:10 -0400
In-Reply-To: <3f9a31f40806151134n1b5e4de7m2ccd9c8a9e98cdb4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-16 at 00:04 +0530, Jaswinder Singh wrote:
> driver source code will goto drivers directory and firmware will goto
> firmware directory.
> Please let us know, how can we keep them in same directory.

Realistically speaking, we can't. Although we'll preserve the option to
build firmware blobs into the kernel image, the primary means of using
them should be running 'make firmware_install' and having them put
into /lib/firmware. It's better for them to be in the firmware/
directory.

If we had the source it might make a _certain_ amount of sense to keep
it with the driver, but this is just a binary blob which we received
from the manufacturer and can't modify anyway (and haven't updated since
the git tree began). It doesn't really help to keep it with the driver.

-- 
dwmw2

