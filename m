From: Andreas Mohr <andi@lisas.de>
Subject: Re: 2.6.23-rc8-mm2 BUG: register_netdevice() issue as (ab)used by
	ISDN
Date: Tue, 9 Oct 2007 21:06:05 +0200
Message-ID: <20071009190605.GA6717@rhlx01.hs-esslingen.de>
References: <20071007120653.GA16184@rhlx01.hs-esslingen.de> <4708D00D.8030307@garzik.org> <20071007131723.GA22873@rhlx01.hs-esslingen.de> <20071007172037.GA29384@rhlx01.hs-esslingen.de> <20071008155836.GA19932@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andreas Mohr <andi@lisas.de>, Jeff Garzik <jeff@garzik.org>,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:45239 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbXJITGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 15:06:09 -0400
Content-Disposition: inline
In-Reply-To: <20071008155836.GA19932@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Oct 08, 2007 at 05:58:36PM +0200, Karsten Keil wrote:
> You could try following patch with 2.6.23-rc8-mm2, it change I4L to use
> alloc_netdev().

I just did the horribly unthinkable:
I rebooted the production internet gateway *remotely*, and:

root@gate:/home/andi# uname -a
Linux gate 2.6.23-rc8-mm2-gate #1 Mon Oct 8 22:14:00 CEST 2007 i586
GNU/Linux
root@gate:/home/andi# dmesg|grep BUG
root@gate:/home/andi# grep BUG /var/log/messages
Oct  7 13:07:40 gate kernel: kernel BUG at net/core/dev.c:3485!
^^^^^^^

This 2.6.23-rc8-mm2-gate was ISDN-patched, obviously.
Oh, and isdnlog *is* indeed running, so this is a first check that
ISDN functionality seems to be up and running...

IOW, thanks!!

Andreas Mohr

-- 
Want to provide valuable development feedback about your kernel version?
Install http://klive.cpushare.com/ !
