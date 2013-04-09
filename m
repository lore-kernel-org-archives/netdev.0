From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [PATCH 0/3 net-next RFC] selftest: Introduce test abstraction for net
Date: Tue,  9 Apr 2013 13:30:58 +0300
Message-ID: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
Cc: willemb@google.com, dborkman@redhat.com, edumazet@google.com,
	Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:43786 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935302Ab3DIKdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 06:33:02 -0400
Received: by mail-bk0-f52.google.com with SMTP id it16so3447190bkc.25
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 03:33:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a generic test abstraction that can make
writing testcases easier. A generic_test structure is
used to define a test and its methods.

The second patch updates the socket tests to use the
new framework, and the third patch creates new tests
for [set/get]sockopt with some IPV6_* options.

Signed-of by Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>

Alexandru Copot (3):
  selftest: add abstractions for net selftests
  selftest: update socket tests to use the testing abstractions
  selftests: add socket options test with IPv6 testcases

 tools/testing/selftests/net/Makefile         |   7 +-
 tools/testing/selftests/net/run_netsocktests |  10 ++
 tools/testing/selftests/net/selftests.c      |  25 ++++
 tools/testing/selftests/net/selftests.h      |  42 +++++++
 tools/testing/selftests/net/socket.c         | 107 +++++++++++-----
 tools/testing/selftests/net/sockopt.c        | 179 +++++++++++++++++++++++++++
 6 files changed, 338 insertions(+), 32 deletions(-)
 create mode 100644 tools/testing/selftests/net/selftests.c
 create mode 100644 tools/testing/selftests/net/selftests.h
 create mode 100644 tools/testing/selftests/net/sockopt.c

-- 
1.8.2
