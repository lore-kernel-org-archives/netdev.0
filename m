From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH 0/3] selftest: Fix build errors
Date: Sun, 18 Jun 2017 09:56:01 +0900
Message-ID: <20170618005604.17639-1-sj38.park@gmail.com>
Cc: bamvor.zhangjian@linaro.org, shorne@gmail.com, davem@davemloft.net,
        linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>
To: shuah@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes build errors in selftest.

SeongJae Park (3):
  selftest/memfd/Makefile: Fix build error
  selftest/intel_pstate/aperf: Use LDLIBS instead of LDFLAGS
  selftest/net/Makefile: Specify output with $(OUTPUT)

 tools/testing/selftests/intel_pstate/Makefile | 2 +-
 tools/testing/selftests/memfd/Makefile        | 2 +-
 tools/testing/selftests/net/Makefile          | 3 +--
 3 files changed, 3 insertions(+), 4 deletions(-)

-- 
2.13.0
