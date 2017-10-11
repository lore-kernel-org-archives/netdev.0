From: Lucas Bates <lucasb@mojatatu.com>
Subject: [PATCH net-next 0/4] tc-testing: Test suite updates
Date: Wed, 11 Oct 2017 17:16:50 -0400
Message-ID: <1507756614-30333-1-git-send-email-lucasb@mojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jhs@mojatatu.com, aring@mojatatu.com, mrv@mojatatu.com,
        Lucas Bates <lucasb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:57327 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752448AbdJKVRO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:17:14 -0400
Received: by mail-it0-f68.google.com with SMTP id g18so4498189itg.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:17:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a roundup of changes to the tc-testing
suite:

 - Add test cases for police and mirred modules and some coverage
   in already-submitted test categories
 - Break the test case files down into more user-friendly sizes
 - Bug fix to the tdc.py script's handling of the -l argument


Lucas Bates (4):
  tc-testing: Add test cases for flushing actions
  tc-testing: Split test case files into smaller chunks
  tc-testing: Add test cases for police and skbmod
  tc-testing: fix the -l argument bug in tdc.py script

 .../tc-testing/tc-tests/actions/gact.json          |  469 ++++++++
 .../selftests/tc-testing/tc-tests/actions/ife.json |   52 +
 .../tc-testing/tc-tests/actions/mirred.json        |  223 ++++
 .../tc-testing/tc-tests/actions/police.json        |  527 +++++++++
 .../tc-testing/tc-tests/actions/simple.json        |  130 +++
 .../tc-testing/tc-tests/actions/skbedit.json       |  320 ++++++
 .../tc-testing/tc-tests/actions/skbmod.json        |  372 +++++++
 .../tc-testing/tc-tests/actions/tests.json         | 1165 --------------------
 tools/testing/selftests/tc-testing/tdc.py          |    8 +-
 9 files changed, 2097 insertions(+), 1169 deletions(-)
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/gact.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/ife.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/mirred.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/police.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/simple.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/skbedit.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/skbmod.json
 delete mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
