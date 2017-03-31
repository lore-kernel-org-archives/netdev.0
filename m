From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] selftests: add a generic testsuite for ethernet device
Date: Fri, 31 Mar 2017 14:57:51 +0200
Message-ID: <20170331125752.20074-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: davem@davemloft.net, shuah@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

My original intent was to add network test to the kernelci project.
Since they use kselftests, they forwarded me to this.

This patch add a basic network test suite which do:
- bring up netdev
- change mac address
- try some ethtool commands
- bring down netdev

The test is non disruptive, so that an already used network interface will
not be modified (mac/IP address for example).

Regards

Corentin Labbe (1):
  selftests: add a generic testsuite for ethernet device

 tools/testing/selftests/net/Makefile     |   2 +-
 tools/testing/selftests/net/netdevice.sh | 185 +++++++++++++++++++++++++++++++
 2 files changed, 186 insertions(+), 1 deletion(-)
 create mode 100755 tools/testing/selftests/net/netdevice.sh

-- 
2.10.2
