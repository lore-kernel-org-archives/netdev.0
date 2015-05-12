From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/2] Run tests forcely in separated netns
Date: Tue, 12 May 2015 17:40:14 +0300
Message-ID: <1431441616-25174-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38336 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932804AbbELOk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 10:40:56 -0400
Received: by wicnf17 with SMTP id nf17so18717060wic.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 07:40:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Changed to run each test in separated network namespace by using
'unshare' tool from util-linux tools set, it allows to do not affect
network setup on the host machine, 'unshare' tool is required by default.

Also added test which checks already fixed BUG related to adding default route.

Vadim Kochan (2):
  tests: Run each test in network namespace
  tests: Add test for 'ip route add default'

 testsuite/Makefile                           |  7 ++++++-
 testsuite/tests/ip/route/add_default_route.t | 12 ++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)
 create mode 100755 testsuite/tests/ip/route/add_default_route.t

-- 
2.3.1
