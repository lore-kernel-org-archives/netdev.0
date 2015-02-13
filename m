From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Subject: [PATCH V3 0/1] tun: dynamically set speed of tun
Date: Fri, 13 Feb 2015 14:19:12 +0800
Message-ID: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <mst@redhat.com>, <jasowang@redhat.com>,
	<viro@zeniv.linux.org.uk>, <davem@davemloft.net>,
	<sergei.shtylyov@cogentembedded.com>, <jonathon.reinhart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:34895 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbbBMGTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 01:19:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V3:

Follow the advice from Jonathon Reinhart, a new patch is made.

V2:

Follow the advice from Sergei, a new patch is made.

V1:

The default speed of tun is 10M while the normal nic speed is 1000M.
When the speed of tun is accessed by the userspace application, the
default 10M is not proper. In this case, the default tun speed is
changed to 1000M. And this speed can be dynamically configured by
the command "ethtool -s tunX speed 10/100/1000".
 
Zhu Yanjun (1):
  tun: change speed from 10M to dynamically configured

 drivers/net/tun.c           | 42 +++++++++++++++++++++++++++++++++++++++++-
 include/uapi/linux/if_tun.h |  5 +++++
 2 files changed, 46 insertions(+), 1 deletion(-)

-- 
1.9.1
