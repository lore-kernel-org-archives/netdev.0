From: Alexei Colin <acolin10@college.harvard.edu>
Subject: sungem on PowerMac G4: RX MAC fifo overflow
Date: Fri, 12 Mar 2010 23:17:35 -0500
Message-ID: <9fa5f2891003122017x72c92682md32c62e272f64380@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:49354 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758800Ab0CMER4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 23:17:56 -0500
Received: by bwz1 with SMTP id 1so1600146bwz.21
        for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 20:17:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Any help on this issue would be greatly appreciated. I am emailing
netdev because I couldn't find anything relevant online (except
ancient inconclusive reports of the same error message).

Issue: system loses Ethernet connectivity after several hours usually
or sooner occasionally. This message gets written to the log multiple
times:
eht0: RX MAC fifo overflow smac[<a mem address>]

Machine: PowerMac G4 (no more firmware updates applicable)
Ethernet: 0002:20:0f.0 Ethernet controller: Apple Computer Inc.
UniNorth GMAC (Sun GEM) (rev 01)
System: Linux 2.6.31-19-powerpc #56-Ubuntu Thu Jan 28 00:50:48 UTC
2010 GNU/Linux
Driver: sungem (srcversion: 9C4DDFB8D2201E852413F4F)

I'd like to think that it started after I updated to Ubuntu 9.10
(different version of sungem), but booting into 2.6.28-6-powerpc
(after the dist upgrade, though) the same is observed.

This does bring back the network:
ifdown eth0; rmmod sungem; modprobe sungem; ifup eth0
(I never tried without reloading the module)

Please let me know if you would like me to get debugging info and
which. Thank you in advance!

Regards,
Alexei
