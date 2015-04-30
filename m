From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 0/6] rhashtable self-test improvements
Date: Thu, 30 Apr 2015 22:37:39 +0000
Message-ID: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33537 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbbD3Why (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:37:54 -0400
Received: by pdbnk13 with SMTP id nk13so74273850pdb.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:37:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves the rhashtable self-test to:
  * Avoid allocation of test objects
  * Measure the time of test runs
  * Use the iterator to walk the table for consistency
  * Account for failed insertions due to memory pressure or
    utilization pressure
  * Ignore failed insertions when checking for consistency

Thomas Graf (6):
  rhashtable-test: Remove unused TEST_NEXPANDS
  rhashtable-test: Measure time to insert, remove & traverse entries
  rhashtable-test: Get rid of ptr in test_obj structure
  rhashtable-test: Do not allocate individual test objects
  rhashtable-test: Use walker to test bucket statistics
  rhashtable-test: Detect insertion failures

 lib/test_rhashtable.c | 214 +++++++++++++++++++++++++++++---------------------
 1 file changed, 123 insertions(+), 91 deletions(-)

-- 
1.9.3
