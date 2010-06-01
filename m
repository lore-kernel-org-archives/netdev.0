From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: Fore 200 firmware
Date: Tue, 01 Jun 2010 11:49:35 -0400
Message-ID: <201006011549.o51FnZFk028507@thirdoffive.cmf.nrl.navy.mil>
References: <alpine.SOC.1.00.1006011747570.22519@math.ut.ee>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:55997 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932110Ab0FAPuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 11:50:03 -0400
In-reply-to: <alpine.SOC.1.00.1006011747570.22519@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <alpine.SOC.1.00.1006011747570.22519@math.ut.ee>,Meelis Roos writes:
>2.5.1 does not seem to contain the firmware.

oops -- i didnt commit it to the repo.

>does not have to redo the detective work I am doing. Packaging it along 
>with linux-atm packages (atm-tools in Debian) does not seem correct, so 
>do we need to make a special firmware package out of it or just add to 
>some other firmware repo that is packaged already?

i dont care which happens really.  i would to think it is part of
atm-tools since the fore200e driver really isnt useful with the
atm tools.

>What's the licence of the firmware anyway - unknown likely?

it says the firmware is gpl.  look at fore200e_firmware_copyright
in one of the old kernel distros.

>And we can probably remove drivers/atm/fore200e_pca_fw.c if we 
>distribute the firmware out of kernel tree.

i dont think it is in the current net-next-2.6 tree?
