From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [PATCH 0/3 RFC v2] selftests: Basic framework for tests
Date: Thu, 25 Apr 2013 14:04:57 +0300
Message-ID: <1366887900-24769-1-git-send-email-alex.mihai.c@gmail.com>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, willemb@google.com, dborkman@redhat.com,
	ebiederm@xmission.com, gorcunov@openvz.org, palewis@adobe.com,
	edumazet@google.com, Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series adds a generic test abstraction that can make
writing testcases easier. A generic_test structure is
used to define a test and its methods: prepare, run, cleanup.

This is a generic implementation so it was placed in selftests/lib.

The second patch updates the socket tests to use the
new framework and the third patch creates new tests
for [set/get]sockopt with some IPV6_* options.

Signed-of-by Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>

Changes since v1:
 - moved the implementation to selftests/lib
 - use goto instead of directly returning

Alexandru Copot (3):
  selftests: introduce testing abstractions
  selftests/net: update socket test to use new testing framework
  selftests/net: add socket options test with IPv6 testcases

 tools/testing/selftests/Makefile             |   3 +-
 tools/testing/selftests/lib/Makefile         |  14 ++
 tools/testing/selftests/lib/selftests.c      |  57 +++++++++
 tools/testing/selftests/lib/selftests.h      |  67 ++++++++++
 tools/testing/selftests/net/Makefile         |  17 ++-
 tools/testing/selftests/net/run_netsocktests |  10 ++
 tools/testing/selftests/net/socket.c         | 108 +++++++++++-----
 tools/testing/selftests/net/sockopt.c        | 185 +++++++++++++++++++++++++++
 8 files changed, 425 insertions(+), 36 deletions(-)
 create mode 100644 tools/testing/selftests/lib/Makefile
 create mode 100644 tools/testing/selftests/lib/selftests.c
 create mode 100644 tools/testing/selftests/lib/selftests.h
 create mode 100644 tools/testing/selftests/net/sockopt.c

-- 
1.8.2.1
