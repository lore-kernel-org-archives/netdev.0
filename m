From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 0/4] connector fixes
Date: Mon, 30 Sep 2013 22:03:05 +0200
Message-ID: <1380571389-15343-1-git-send-email-minipli@googlemail.com>
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:43396 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756399Ab3I3UD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 16:03:26 -0400
Received: by mail-bk0-f51.google.com with SMTP id mx10so2234279bkb.24
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 13:03:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes a few netlink related issues of the connector interface.

The first two patches are bug fixes. The last two are cleanups.

Please apply!


Mathias Krause (4):
  proc connector: fix info leaks
  connector: use nlmsg_len() to check message length
  connector: use 'size' everywhere in cn_netlink_send()
  connector - documentation: simplify netlink message length assignment

 Documentation/connector/ucon.c |    2 +-
 drivers/connector/cn_proc.c    |   18 ++++++++++++++++++
 drivers/connector/connector.c  |    9 +++++----
 3 files changed, 24 insertions(+), 5 deletions(-)

-- 
1.7.10.4
