From: yoshfuji@linux-ipv6.org
Subject: iputils-s20121114
Date: Wed, 14 Nov 2012 22:50:20 +0900
Message-ID: <201211141350.qAEDoKFv006775@94.43.138.210.xn.2iij.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:52957 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab2KNNuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 08:50:22 -0500
Received: from 94.43.138.210.xn.2iij.net (yoshfuji@localhost [127.0.0.1])
	by 94.43.138.210.xn.2iij.net (8.13.8/8.13.8/Debian-3+etch1) with ESMTP id qAEDoK7Q006779
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 22:50:20 +0900
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

iputils-s20121114 comes with a lot of bug fixes and improvements, thanks to
distro bug reports.

Files:
	https://sourceforge.net/projects/iputils/files/
	http://www.skbuff.net/iputils/
Tree:
	http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=gitroot/iputils.git
	https://sourceforge.net/p/iputils/code/ci/HEAD/tree/

Regards,

--yoshfuji

Changes between s20121106 and s20121112:

Sergey Fionov (1):
      ping,ping6: Fallback to numeric addresses while exiting

YOSHIFUJI Hideaki (19):
      ping,ping6: Rework capability support and Make sure -m and -I options work.
      ping,tracepath: Spelling fixes in manpages.
      ping,ping6: Fix integer overflow with large interval value (-i option).
      clockdiff: Make it work with large pid.
      ping,ping6: Make in_pr_addr volatile.
      arping: Do not quit too early with large deadline value (-w option).
      arping: Maintain minimum capabilities for SO_BINDTODEVICE(-I option).
      ping: Fix recorded route comparison.
      arping: Use getifaddrs() to get broadcast address.
      ping6: Fix typo in error message.
      ping6: Generate NI Group Address and Subject Name at once.
      ping,ping6: Unmask signals on start-up.
      arping: Build with USE_CAP=no.
      arping,ping,ping6,tracepath,tracepath6,traceroute6: Experimental IDN support.
      ping6: IDN support for the Subject Name in NI Query.
      tracepath,tracepath6: Introduce -p option for port.
      ping6: Add missing definitions/declarations for flowlabel management (-F option).
      makefile: Do not include merge commits in RELNOTES.
      iputils-s20121112

Changes since iputils-s20121112:

Jan Synacek (2):
      clockdiff: remove unused variable
      ping: Wrap SO_BINDTODEVICE with the correct capability.

YOSHIFUJI Hideaki (14):
      ping: IP_MULTICAST_IF does not need CAP_NET_RAW.
      ping6: Check ranges of flowlabel (-F option) and tclass (-Q option) arguments.
      ping6: Accept 0x-notation for flowlabel (-F option) and tclass (-Q option) arguments.
      ping,ping6: Manual update regarding -F, -Q and -N option.
      arping,ping,ping6: Defer exitting to allow users to see usage.
      arping,ping,ping6,ninfod: Change euid to uid (non-root) even if capabiliy is enabled.
      ninfod: Add configure.
      ninfod: libcap support to drop capabilities.
      ninfod: Add run as user (-u user) option.
      ninfod: Fix usage message.
      arping,clockdiff,rarpd,rdisc,tftpd: Change RFC source to tools.ietf.org.
      ninfod: Add ninfod(8) manpage.
      makefile: Add ninfod, distclean targets.
      iputils-s20121114
