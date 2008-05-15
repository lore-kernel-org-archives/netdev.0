From: Greg KH <greg@kroah.com>
Subject: Network drivers with direct io memory accesses
Date: Wed, 14 May 2008 17:10:44 -0700
Message-ID: <20080515001044.GA2772@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41301 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990AbYEOALN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 20:11:13 -0400
Received: from dsl093-040-174.pdx1.dsl.speakeasy.net ([66.93.40.174] helo=localhost)
	by pentafluge.infradead.org with esmtpsa (Exim 4.68 #1 (Red Hat Linux))
	id 1JwR3w-00055K-3V
	for netdev@vger.kernel.org; Thu, 15 May 2008 00:11:12 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm currently sitting on two network drivers:
 Alacritech gigabit driver that supports 3 different classes of cards:
  http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/ldp/net-add-alacritech-slicoss-driver.patch

 ET1310 network driver
  http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/ldp/net-add-et131x-driver.patch

Both of these drivers are accessing memory on the devices directly,
without using the proper kernel abstractions for it, making them usable
only on x86-based boxes probably.

My question is, does this have to be fixed in order to get them
accepted into the tree?  It's going to be a very big effort to fix them
up from what I can tell.  I don't mind, it's just going to take a while,
and I'm wondering if people want to use these drivers sooner than the
month or so it's going to take me (at the least.)

Yes, I know the Alacritech driver still has the firmware in the patch
itself, that will be moved out, I know, and there are probably other
minor issues left to clean up in each of these drivers, that's not the
point here...

Any thoughts?

thanks,

greg k-h
