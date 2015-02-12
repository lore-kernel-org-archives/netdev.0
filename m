From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Subject: [PATCH 0/1] tun: dynamically set speed of tun
Date: Thu, 12 Feb 2015 13:35:22 +0800
Message-ID: <1423719323-4667-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <mst@redhat.com>, <jasowang@redhat.com>,
	<viro@zeniv.linux.org.uk>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64957 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbbBLFfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 00:35:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default speed of tun is 10M while the normal nic speed is 1000M. 
When the speed of tun is accessed by the userspace application, the
default 10M is not proper. In this case, the default tun speed is 
changed to 1000M. And this speed can be dynamically configured by
the command "ethtool -s tunX speed 10/100/1000".

Zhu Yanjun (1):
  tun: change speed from 10M to dynamically configured

 drivers/net/tun.c           | 36 +++++++++++++++++++++++++++++++++++-
 include/uapi/linux/if_tun.h |  5 +++++
 2 files changed, 40 insertions(+), 1 deletion(-)

-- 
1.9.1
