From: Lucas Bates <lucasb@mojatatu.com>
Subject: [PATCH net-next v2 0/4] tc-testing: Test suite updates
Date: Fri, 13 Oct 2017 17:51:21 -0400
Message-ID: <1507931485-1814-1-git-send-email-lucasb@mojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jhs@mojatatu.com, aring@mojatatu.com, mrv@mojatatu.com,
        Lucas Bates <lucasb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:55789 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751624AbdJMVvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 17:51:39 -0400
Received: by mail-io0-f195.google.com with SMTP id p186so4242223ioe.12
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 14:51:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a roundup of changes to the tc-testing
suite:

 - Add test cases for police and mirred modules and some coverage
   in already-submitted test categories
 - Break the test case files down into more user-friendly sizes
 - Bug fix to the tdc.py script's handling of the -l argument

v2: fix the lack of final newlines in two new files (thanks David)

Lucas Bates (4):
  tc-testing: Add test cases for flushing actions
  tc-testing: Split test case files into smaller chunks
  tc-testing: Add test cases for police and skbmod
  tc-testing: fix the -l argument bug in tdc.py

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
