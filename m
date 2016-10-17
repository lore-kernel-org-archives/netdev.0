From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] bridge-utils 1.6 release
Date: Mon, 17 Oct 2016 09:03:30 -0700
Message-ID: <20161017090330.270fe160@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36208 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935363AbcJQQDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 12:03:16 -0400
Received: by mail-pf0-f173.google.com with SMTP id e6so80590749pfk.3
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 09:03:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Release of bridge-utils version 1.6

This is the first bridge-utils release in a long time.
There are not any new features, since bridge-utils is deprecated in
favor of bridge command in iproute2. But there are several small
bug fixes and minor cleanups.

Source:
  http://www.kernel.org/pub/linux/utils/net/bridge-utils/bridge-utils.1.6.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

---
Andrey Mazo (4):
      bridge-utils: Abort compilation on error in any subdirectory
      bridge-utils: Remove unused variable in doc/Makefile.in
      bridge-utils: AC_OUTPUT should be used without arguments
      bridge-utils: Pretty print configure help

David Johnson (1):
      bug with older glibc: "brctl show" shows nothing

Kylie McClain (1):
      Fix building on musl libc

Russell Senior (1):
      bridge-utils: Fix compile against linux-3.8.x

Stephen Hemminger (10):
      Fix incorrect command in manual
      Fix error message for incorrect command
      Check error returns from write to sysfs
      Fix typo's on man page
      update email address
      ignore build files
      Clean up autoconf debris when doing make maintainer-clean
      brctl: better error handling
      man: add obsolete notice to man page
      bridge-utils 1.6 release

Xiaochen Wang (1):
      skip . and .. in accurately in isbridge()

Yegor Yefremov (1):
      rename configure.in to configure.ac
