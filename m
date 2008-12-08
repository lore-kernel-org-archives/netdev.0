From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: Nasty regression from .27.7 to .27.8: idle samba goes crazy
Date: Mon, 08 Dec 2008 17:46:20 +0100
Message-ID: <493D4F5C.7020606@s5r6.in-berlin.de>
References: <pan.2008.12.08.06.18.57.357875@wizards.de> <200812080834.22924.rjw@sisk.pl> <pan.2008.12.08.08.07.29.439625@wizards.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Holger Hoffstaette <holger@wizards.de>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Greg KH <greg@kroah.com>, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:57177 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258AbYLHQqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 11:46:30 -0500
In-Reply-To: <pan.2008.12.08.08.07.29.439625@wizards.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holger Hoffstaette wrote at LKML:
> On Mon, 08 Dec 2008 08:34:22 +0100, Rafael J. Wysocki wrote:
> 
>> On Monday, 8 of December 2008, Holger Hoffstaette wrote:
>>> Hi,
>>> 
>>> I just encountered a nasty symptom for the second time that has started to
>>> occur after updating my home server from vanilla 2.6.27.7 to .8 (same
>>> config).
>>> 
>>> A while after disconnecting a samba client, the smbd samba server
>>> process goes crazy and consumes 100% CPU. From that time on it is
>>> unkillable (kill -9 returns but the process continues to run). The only
>>> recourse is reboot, which works without problem (i.e. unmounting the
>>> served filesystems is apparently possible?). I tried to attach to the
>>> process with gdb but that just hung.
>>> 
>>> The system is a generic old single-core P4 box with a single SATA drive,
>>> Gentoo userland and Samba is 3.0.33 (in async mode). The kernel has no
>>> patches or binary drivers. It has been rock solid before the update and
>>> shows no other signs of weirdness in logs or otherwise. I downgraded to .7
>>> for now and will see what happens, but since it worked before I am certain
>>> that this is a regression in the .8 release.
>>> 
>>> The only commonality is a log entry by samba that seems to correlate with
>>> both occurrences:
>>> 
>>> [2008/12/08 01:02:52, 0] lib/util_sock.c:read_data(534)
>>>   read_data: read failure for 4 bytes to client 192.168.100.128. Error = No route to host
>>> 
>>> .128 is the Windows client machine (connected via a stable GigE link),
>>> which I shut down pretty much exactly 30 minutes before that (any 30
>>> minute timeouts in the kernel/network stack?). Both instances of these log
>>> entries correlate with the CPU spikes which I noticed in my MRTG graphs.
>>> 
>>> Any suspects or ideas?
>>> 
>>> thanks
>>> Holger
>> 
>> Please bisect.
> 
> I would love to try, but this is my "production server" (i.e. I need it
> for real work) and I'll be traveling the next few days. I will try to
> bisect after that (if nobody else has any ideas) but will have to make
> sure the bug is actually reproducible after the timeout - for now I only
> observed it by accident (via mrtg).
> In the meantime maybe someone else will observe it as well.
> 
> thanks
> Holger
> 

Added Cc: netdev, readded all other Cc's, quoted in full for netdev.
Good luck,
-- 
Stefan Richter
-=====-==--- ==-- -=---
http://arcgraph.de/sr/
