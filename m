From: "Art Haas" <ahaas@airmail.net>
Subject: Debugging kernel lockups during network activity
Date: Thu, 27 Jul 2006 13:19:43 -0500
Message-ID: <20060727181943.GD23091@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8f.7b.d1c4.cidr.airmail.net ([209.196.123.143]:63244 "EHLO
	covert.brown-ring.iadfw.net") by vger.kernel.org with ESMTP
	id S1750951AbWG0SUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 14:20:44 -0400
Received: from cpe-24-28-121-3.houston.res.rr.com ([24.28.121.3] helo=pcdebian)
	by covert.iadfw.net with esmtp (Exim 4.24)
	id 1G6AYb-0000fC-69
	for netdev@vger.kernel.org; Thu, 27 Jul 2006 13:26:01 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I've got Fedora Rawhide running on a SMP PIII machine, and the latest
kernels from Fedora have been locking up when I run 'yum update' to
get the latest packages. I also experience lock-ups when I use
Firefox to do some web browsing. Not all my network usage results in a
lockup, however. I can usually do 'git pull' and update git itself or
my copy of Linus' kernel tree without problems, as well as update my
GCC repo with subversion and Mozilla with cvs. I realize that running
Fedora Rawhide means when things break I can keep the pieces, so
the lockups or other occasional issues are not unexpected.

I'm writing to the 'netdev' list in an effort to get some pointers as to
how I can try and debug the problem. When I boot off my FC5 install
disk and run 'linux rescue' I can chroot to the system and update
the machine without problems, and I've also run memtest86 on it and
found no memory issues, so I'm certain the problem is in the Fedora
kernel. I don't know how to try and narrow down the problem to provide a
decent bug report, or if there is/are settings I can adjust which may
help to identify what is happening.

I'd mailed the fedora-test list and received no response, so I thought I
could try the main network development list. Are there a few tips,
tricks, or pointers that could be sent my way which others use to debug
networking problems like the one described above? Thanks in advance, and
my thanks to everyone working on the kernel.

Art Haas
-- 
Man once surrendering his reason, has no remaining guard against absurdities
the most monstrous, and like a ship without rudder, is the sport of every wind.

-Thomas Jefferson to James Smith, 1822
