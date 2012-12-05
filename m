From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: iputils-s20121205
Date: Thu, 6 Dec 2012 00:13:11 +0900
Message-ID: <201212051513.qB5FDBox027662@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41329 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667Ab2LEPNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 10:13:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

iputils-s20121205 has been released.  Diffstat and changelog below.

Files:
        https://sourceforge.net/projects/iputils/files/
        http://www.skbuff.net/iputils/
Tree:
        http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=gitroot/iputils.git
        https://sourceforge.net/p/iputils/code/ci/HEAD/tree/

Regards,

--yoshfuji

[Diffstat]

 Makefile                |   82 +++++++++++++++++++---------
 RELNOTES                |   43 +++++++++++++++
 SNAPSHOT.h              |    2 -
 arping.c                |  138 +++++++++++++++++++++++++++++------------------
 doc/docbook2man-spec.pl |    4 +
 doc/ping.sgml           |   14 +++--
 doc/snapshot.db         |    2 -
 doc/tracepath.sgml      |    3 +
 iputils.spec            |   97 +++++++++++++++++++--------------
 ping.c                  |   42 ++++++++++++++
 ping6.c                 |   31 ++++++++++-
 ping_common.c           |   74 ++++++++++++++-----------
 rdisc.c                 |   10 +++
 tracepath.c             |   20 ++++---
 tracepath6.c            |   46 +++++++++++-----
 15 files changed, 421 insertions(+), 187 deletions(-)

[Changelog]
Jan Synacek (1):
      ping,tracepath doc: Fix missing end tags.

YOSHIFUJI Hideaki (36):
      tracepath6: packet length option (-l) did not have any effect.
      tracepath,tracepath6: Fix pktlen message.
      tracepath,tracepath6: Use calloc(3) instead of using stack.
      tracepath6: Ignore families other than IPv4 and IPv6.
      ping6: Improve randomness of NI Nonce.
      tracepath,tracepath6 doc: Fix default pktlen.
      ping,rdisc: Optimize checksumming.
      makefile: Static link support for crypto, resolv, cap and sysfs.
      doc: Ajdust spaces around sqare brackets.
      ping,rdisc: Use macro to get odd byte when checksumming.
      ping6: Do not try to free memory pointed by uninitialized variable on error path.
      arping: Allow building without default interface.
      arping: No default interface by default.
      arping: Allow printing usage without permission errors.
      ping,ping6: Allow printing usage without permission errors.
      ping,ping6: Fix cap_t leakage.
      arping,ping,ping6: Do not ideologically check return value from cap_free,cap_{set,get}_flag().
      arping: Fix sysfs_class leakage on error path.
      arping: Some comments for new functions for finding devices support.
      arping: Typo in type declaration.
      makefile: Use call function for external libraries.
      makefile: Add more comments.
      arping: Ensure to fail if no appropriate device found with sysfs.
      arping: Enforce user to specify device (-I) if multiple devices found.
      Makefile: parameterize options for linking libraries.
      Makefile: Use shell function instead if backquotes.
      Makefile: Ensure to have same date when making snapshot.
      spec: Maintainer does not use ipsec.spec.
      spec: partially sync with fedora.
      Makefile: Bump date in iputils.spec as well.
      spec: Add exmple lines for suid-root installation
      spec: Sort changelog.
      ping: Exit on SO_BINDTODEVICE failure.
      ping: Warn if kernel has selected source address from other interface.
      ping: Clarify difference between -I device and -I addr.
      iputils-s20121205
