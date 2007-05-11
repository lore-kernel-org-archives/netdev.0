From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 08/13] Use menuconfig objects II - netdev
 (general+100mbit)
Date: Fri, 11 May 2007 14:58:51 -0700
Message-ID: <20070511145851.6e110e3c.akpm@linux-foundation.org>
References: <200705110552.l4B5quBQ007813@shell0.pdx.osdl.net>
	<4644D8D0.3080602@garzik.org>
	<Pine.LNX.4.61.0705112331440.9570@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:44164 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751349AbXEKV7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 17:59:01 -0400
In-Reply-To: <Pine.LNX.4.61.0705112331440.9570@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 May 2007 23:32:08 +0200 (MEST)
Jan Engelhardt <jengelh@linux01.gwdg.de> wrote:

> 
> On May 11 2007 16:57, Jeff Garzik wrote:
> >> 
> >> CONFIG_NETDEVICES, CONFIG_NET_ETHERNET:
> >> Change Kconfig objects from "menu, config" into "menuconfig" so
> >> that the user can disable the whole feature without having to
> >> enter the menu first.
> >> 
> >> CONFIG_SMC9194:
> >> Move it so that it appears correctly in menuconfig.
> >> 
> >> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
> >> Cc: Jeff Garzik <jeff@garzik.org>
> >> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >> ---
> >> 
> >> drivers/net/Kconfig         |  167 ++++++++++++++++------------------
> >> drivers/net/arm/Kconfig     |   12 +-
> >> drivers/net/fec_8xx/Kconfig |    2 drivers/net/fs_enet/Kconfig |    2
> >> drivers/net/tulip/Kconfig   |   27 ++---
> >> 5 files changed, 102 insertions(+), 108 deletions(-)
> >
> > ACK, but failed to apply
> >
> Name the tree that I should rebase it on. (Did not seem like basing
> everything on -mm always works out.)
> 

Is OK.  It applies OK here, but is obviously geting rejects due to all the
other maintainers who have their sticky paws on Jeff's stuff.

akpm:/usr/src/25> for i in drivers/net/Kconfig drivers/net/arm/Kconfig drivers/net/fec_8xx/Kconfig drivers/net/tulip/Kconfig
for> do
for> grep -l $i pc/git-*.pc
for> done | sort | uniq
pc/git-infiniband.pc
pc/git-qla3xxx.pc
pc/git-wireless.pc

I'll just continue to maintain the patch and one day the conflicting
changes will make it into mainline and the patch will then apply on Jeff's
tree.  Ho hum.

