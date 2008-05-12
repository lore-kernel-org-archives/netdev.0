From: ackman <ackman@gtf.org>
Subject: RTL8169 driver no longer functioning with 8111b
Date: Mon, 12 May 2008 16:39:21 -0700
Message-ID: <4828D529.3060201@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:57157 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756903AbYELXtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 19:49:24 -0400
Received: from [127.0.0.1] (cpe-76-167-243-198.socal.res.rr.com [76.167.243.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by havoc.gtf.org (Postfix) with ESMTP id C92CA1F81A2
	for <netdev@vger.kernel.org>; Mon, 12 May 2008 19:39:23 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've spent the better part of a day researching this to no avail.  I run 
Gentoo on an Abit AB9 PRO P965 board.  It has two onboard ports for a 
Realtek 8111B Gigabit interface.  I have been running 2.6.23-gentoo-r8 
(I think) kernel sources.  I went to reboot the unit, something I've 
done many times before, and upon reboot the two NICs were recognized but 
there was no network.  The link status for one was down (my primary port 
where the NIC cable has always been), while the other port showed a link 
status of yes.  Neither change regardless of cable now.  Also, all other 
values are pretty much *unknown*.  If I turn off the machine, the link 
status light (both on the port and my switch) is lit until the kernel 
module for r8169 is loaded, and then the link light goes off (both on 
the port and my switch).

For the life of me, I don't know what has changed short of general 
software updates in Gentoo.  I scoured the web, find suggestions about 
where Windows has turned the NIC off.  The trouble is I don't use 
Windows period on this box, no do I have the software to even test the 
theory of the power savings being turn on.  It just mysteriously has 
stopped being alive.  lspci shows the devices, their given eth0 and eth1 
as usual, I can disable them in the bios and watch Linux recognize 
they're missing, but still I can't for the life of me get them to act 
properly.  I've tried turning off ACPI, I've tried 2.6.24-gentoo-r7 
kernel, I've tried the Realtek driver source for r8168.  ACPI support 
was the only thing I can think of that has been a major change on the 
system anytime recently. 

Any suggestions would be helpful.
How might I turn off the power saving feature in the chip via linux?

-Ack

