From: Lucas Bates <lucasb@mojatatu.com>
Subject: [PATCH net-next 0/1] Introduction of the tc tests
Date: Fri, 16 Jun 2017 17:22:34 -0400
Message-ID: <1497648155-25521-1-git-send-email-lucasb@mojatatu.com>
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        jiri@resnulli.us, xiyou.wangcong@gmail.com, mrv@mojatatu.com,
        jhs@mojatatu.com, Lucas Bates <lucasb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33322 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdFPVXE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 17:23:04 -0400
Received: by mail-io0-f195.google.com with SMTP id j200so5972857ioe.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 14:23:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apologies for sending this as one big patch. I've been sitting on this a little
too long, but it's ready and I wanted to get it out.

There are a limited number of tests to start - I plan to add more on a regular
basis.

Lucas Bates (1):
  selftests: Introduce tc testsuite

 tools/testing/selftests/tc-testing/.gitignore      |    1 +
 tools/testing/selftests/tc-testing/README          |  102 ++
 tools/testing/selftests/tc-testing/TODO.txt        |   10 +
 .../creating-testcases/AddingTestCases.txt         |   69 ++
 .../tc-testing/creating-testcases/template.json    |   40 +
 .../tc-testing/tc-tests/actions/tests.json         | 1115 ++++++++++++++++++++
 .../tc-testing/tc-tests/filters/tests.json         |   21 +
 tools/testing/selftests/tc-testing/tdc.py          |  413 ++++++++
 tools/testing/selftests/tc-testing/tdc_config.py   |   17 +
 tools/testing/selftests/tc-testing/tdc_helper.py   |   75 ++
 10 files changed, 1863 insertions(+)
 create mode 100644 tools/testing/selftests/tc-testing/.gitignore
 create mode 100644 tools/testing/selftests/tc-testing/README
 create mode 100644 tools/testing/selftests/tc-testing/TODO.txt
 create mode 100644 tools/testing/selftests/tc-testing/creating-testcases/AddingTestCases.txt
 create mode 100644 tools/testing/selftests/tc-testing/creating-testcases/template.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
 create mode 100644 tools/testing/selftests/tc-testing/tc-tests/filters/tests.json
 create mode 100755 tools/testing/selftests/tc-testing/tdc.py
 create mode 100644 tools/testing/selftests/tc-testing/tdc_config.py
 create mode 100644 tools/testing/selftests/tc-testing/tdc_helper.py
