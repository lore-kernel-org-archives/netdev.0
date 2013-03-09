From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 0/3] net: netlink info leak fixes
Date: Sat,  9 Mar 2013 16:52:18 +0100
Message-ID: <1362844341-12591-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:56012 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759056Ab3CIPwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 10:52:43 -0500
Received: by mail-bk0-f42.google.com with SMTP id jk7so1128173bkc.29
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 07:52:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

a few more info leak fixes -- this time in rtnl.

Please apply!

Mathias Krause (3):
  bridge: fix mdb info leaks
  rtnl: fix info leak on RTM_GETLINK request for VF devices
  dcbnl: fix various netlink info leaks

 net/bridge/br_mdb.c  |    4 ++++
 net/core/rtnetlink.c |    1 +
 net/dcb/dcbnl.c      |    8 ++++++++
 3 files changed, 13 insertions(+)

-- 
1.7.10.4
