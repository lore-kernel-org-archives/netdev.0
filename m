From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Ethernet driver for SNI RM200/RM400 machines
Date: Tue, 24 Apr 2007 00:00:10 +0200
Message-ID: <20070423220010.GA9541@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:48338 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988AbXDWXMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 19:12:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm currently working on getting LINUX supported on SNI RM200/300/400
machines (MIPS based servers and workstations). Most of the changes
are already in Linus tree. What's now missing are some device drivers.
One is an ethernet driver for the older EISA only RM200 and RM400
machines. They are using an Intel 82596 ethernet chip. Currently
there are 3 more or less different 82596 drivers in the tree, so
I didn't want to add another modified copy. I took lasi_82596.c,
extracted the common parts, put that in its own file and used
that for lasi_82956.c and sni_82596.c. The patch is about 89k
big, therefore I've placed it offline:

http://www.alpha.franken.de/patches/sni_82596.diff

The driver is tested on a HP B132 and a SNI RM400-220.

I've already looked at 82596.c, which contains a 82596 driver for
MVME boards. It's no big deal to use lib82596.c as well for
that driver. Right now my VME gear is not usable for testing,
so if anybody has hardware to test such a modified driver, please
mail me.

It would be great, if this driver could be included during the 2.6.22
release cycle.

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
