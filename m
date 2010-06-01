From: Meelis Roos <mroos@linux.ee>
Subject: Re: Fore 200 firmware
Date: Tue, 1 Jun 2010 19:09:17 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1006011902490.22519@math.ut.ee>
References: <201006011549.o51FnZFk028507@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:59843 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756579Ab0FAQJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 12:09:18 -0400
In-Reply-To: <201006011549.o51FnZFk028507@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >does not have to redo the detective work I am doing. Packaging it along 
> >with linux-atm packages (atm-tools in Debian) does not seem correct, so 
> >do we need to make a special firmware package out of it or just add to 
> >some other firmware repo that is packaged already?
> 
> i dont care which happens really.  i would to think it is part of
> atm-tools since the fore200e driver really isnt useful with the
> atm tools.

OK, so we should push the distro maintainers of it to create a suggested 
firmware package or just include the fore firmware unconditionally - 
once it is in released linux-atm.

> >What's the licence of the firmware anyway - unknown likely?
> 
> it says the firmware is gpl.  look at fore200e_firmware_copyright
> in one of the old kernel distros.

Well, there is no source to fulfill the GPL... but there also should be 
no problem redistributing it.

> >And we can probably remove drivers/atm/fore200e_pca_fw.c if we 
> >distribute the firmware out of kernel tree.
> 
> i dont think it is in the current net-next-2.6 tree?

Oops, you are right - I have updated my tree over several years and the 
old files were just not removed from disk. But theay are gone from the 
git, yes.

Thnak yo for your work on ATM - I intend to get a demo ATM network 
running here in my computer museum.

-- 
Meelis Roos (mroos@linux.ee)
