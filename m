From: Peter Fassberg <pf@leissner.se>
Subject: Activate netns
Date: Thu, 27 Mar 2014 15:51:37 +0100 (SNT)
Message-ID: <alpine.BSF.2.00.1403271539380.78113@nic-i.leissner.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.leissner.se ([212.3.1.210]:31784 "EHLO
	mailgate.leissner.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594AbaC0PQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 11:16:51 -0400
Received: from mailgate.leissner.se (localhost [127.0.0.1])
	by mailgate.leissner.se (8.14.8/8.14.8) with ESMTP id s2REpgke045455
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 15:51:42 +0100 (CET)
	(envelope-from pf@leissner.se)
Received: (from uucp@localhost)
	by mailgate.leissner.se (8.14.8/8.14.8/Submit) id s2REpfFc045451
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 15:51:41 +0100 (CET)
	(envelope-from pf@leissner.se)
Received: from nic-i.leissner.se (localhost [127.0.0.1])
	by nic-i.leissner.se (8.14.8/8.14.7) with ESMTP id s2REpbwZ044773
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 15:51:37 +0100 (CET)
	(envelope-from pf@leissner.se)
Received: from localhost (pf@localhost)
	by nic-i.leissner.se (8.14.8/8.14.7/Submit) with ESMTP id s2REpbsH044770
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 15:51:37 +0100 (CET)
	(envelope-from pf@leissner.se)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi!

I have trouble to activate netns on OpenWrt with kernel 3.8.13.

I get this:

root@ROOter:~# ip netns show
root@ROOter:~# ip netns add blue
Failed to create a new network namespace "blue": Invalid argument
root@ROOter:~# df
Filesystem           1K-blocks      Used Available Use% Mounted on
rootfs                   48377     10493     37884  22% /
/dev/root                48377     10493     37884  22% /
tmpfs                   257036      2264    254772   1% /tmp
tmpfs                      512         0       512   0% /dev
/dev/sda2                 4088      2266      1618  58% /mnt
/dev/sda1                 4088      2266      1618  58% /mnt
tmpfs                   257036      2264    254772   1% /tmp/run/netns
root@ROOter:~# uname -a
Linux ROOter 3.8.13 #2 Wed Mar 26 21:39:04 CET 2014 i686 GNU/Linux
root@ROOter:~#


Any hints on what I'm missing?



Regards,

// Peter
