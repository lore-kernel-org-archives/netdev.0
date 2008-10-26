From: Marcel Holtmann <holtmann@linux.intel.com>
Subject: Re: [PATCH] wireless: fix regression caused by regulatory config
	option
Date: Sun, 26 Oct 2008 23:12:37 +0100
Message-ID: <1225059157.7157.3.camel@californication>
References: <20081026103024.2712ddc9@infradead.org>
	 <20081026200939.GC12648@tuxdriver.com>
	 <20081026131818.7517c103@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, rodriguez@atheros.com,
	johannes@sipsolutions.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:56281 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbYJZVMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 17:12:36 -0400
In-Reply-To: <20081026131818.7517c103@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arjan,

> > > Change the default to "y" and also adjust the config text a little
> > > to reflect this.
> > 
> > Is it common practice to have compatibility options default to
> > "y"?  I'm not saying it shouldn't be, just wondering if it has been
> > traditionally?
> 
> yes
> 
> default should be "keep working as before"
> 
> it's not always nice, especially if you're trying to get rid of some
> nasty stuff, but think of it this way: you should be able to use a
> new kernel on an existing distro, at least for a reasonable type of
> distro (eg something shipped in, say, the last 2 years). In this case:
> even Fedora 10 is not likely to work!

I think with the new patches from Johannes to make the regulatory
interaction easier for hardware that has hardware/EEPROM based
regulatory enforcement like our wireless cards, it should be all good.

That seems to be 2.6.20 stuff and then it seems to be safe to remove the
WIRELESS_OLD_REGULATORY option and it would still work with old
userspace (or missing crda/iw) in cases the hardware does regulatory
enforcement.

Regards

Marcel


