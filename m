From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH iproute2 v2 0/2] two improvements in tc
Date: Thu, 16 Jan 2014 11:09:12 +0800
Message-ID: <1389841754-22008-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:20693 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548AbaAPDJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 22:09:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support sending burst/mtu to kernel directly in tbf.
Support 64bit rate in netem.

v1 -> v2:
  patch 2/2: Use rta_getattr_u64() to get value of rate64.

Yang Yingliang (2):
  tbf: support sending burst/mtu to kernel directly
  netem: add 64bit rates support

 tc/q_netem.c | 29 ++++++++++++++++++++++++-----
 tc/q_tbf.c   |  2 ++
 2 files changed, 26 insertions(+), 5 deletions(-)

-- 
1.8.0
