From: Stefan Becker <chemobejk@gmail.com>
Subject: Re: [PATCH] r8169: Fix WOL in power down case
Date: Thu, 3 Nov 2011 17:27:12 +0000 (UTC)
Message-ID: <loom.20111103T181827-952@post.gmane.org>
References: <20111007221906.810698ba9bf825566a2478bb@gmx.de> <20111007210017.GA27820@electric-eye.fr.zoreil.com> <20111007214200.GA28365@electric-eye.fr.zoreil.com> <20111008003156.ef4dfaa76576ca8079edfbb9@gmx.de> <20111007232834.GA29770@electric-eye.fr.zoreil.com> <20111009104907.0c6cd439900ca5eb7789295f@gmx.de> <20111009115438.GA12343@electric-eye.fr.zoreil.com> <20111009191331.cbfca0b6b724921f35fd8c41@gmx.de> <loom.20111101T174532-579@post.gmane.org> <20111102230827.GA8974@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:46184 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754719Ab1KCR1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Nov 2011 13:27:33 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RM14c-0005OX-JE
	for netdev@vger.kernel.org; Thu, 03 Nov 2011 18:27:30 +0100
Received: from 86-60-137-83-dyn-dsl.ssp.fi ([86.60.137.83])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2011 18:27:30 +0100
Received: from chemobejk by 86-60-137-83-dyn-dsl.ssp.fi with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2011 18:27:30 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu <at> fr.zoreil.com> writes:
> 
> Plain power down, not suspend/resume ?

Plain power down, i.e. the system uses "shutdown -h now".


> However I am almost sure the regression would come from a different commit
> and I'd rather identify it. Can you narrow the kernel version a bit ?
> Your vendor's kernel identifier before regression would be a good start.
 
Here are my test results for vanilla Linux kernel sources, "defconfig +
CONFIG_EXT4_FS=y" and Fedora 16 user space:

     Commit        WoL

     v3.1          BROKEN
     92fc43b4159   BROKEN
     4f6b00e5f13   WORKS    (== 92fc43b4159^)
     v3.0          WORKS

So WoL for my HW is broken by the same commit 92fc43b4159.

Regards,

      Stefan
