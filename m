From: Meelis Roos <mroos@linux.ee>
Subject: Re: Fore 200 firmware
Date: Tue, 1 Jun 2010 17:52:23 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1006011747570.22519@math.ut.ee>
References: <201006011437.o51Ebp6f014332@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:48410 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756364Ab0FAOwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 10:52:25 -0400
In-Reply-To: <201006011437.o51Ebp6f014332@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >So the current state is that drivers/atm contains the C dump of fore 200 
> >firmware in drivers/atm/fore200e_pca_fw.c but this firmware is not built 
> >and not installed by make install. It's also not present in 
> >linux-firware tree/packages so the fore driver can not load its firmware 
> >from anywhere. I guess this is not the intended outcome.
> 
> this firmware is in the linux-atm source tree now.  the 2.5.1 release
> should have the firmware.

2.5.1 does not seem to contain the firmware.

Even if it will be there in the next release, we should still do 
something to distribute it to the user so that any modern distro has the 
firmware available (in linux-firmware or via similar means) so the user 
does not have to redo the detective work I am doing. Packaging it along 
with linux-atm packages (atm-tools in Debian) does not seem correct, so 
do we need to make a special firmware package out of it or just add to 
some other firmware repo that is packaged already?

What's the licence of the firmware anyway - unknown likely?

And we can probably remove drivers/atm/fore200e_pca_fw.c if we 
distribute the firmware out of kernel tree.

-- 
Meelis Roos (mroos@linux.ee)
