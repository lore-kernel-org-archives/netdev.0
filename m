From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH iproute2 0/2] two improvements in tc
Date: Wed, 15 Jan 2014 17:42:10 +0800
Message-ID: <1389778932-17404-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:33764 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbaAOJnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 04:43:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support sending burst/mtu to kernel directly in tbf.
Support 64bit rate in netem.

Yang Yingliang (2):
  tbf: support sending burst/mtu to kernel directly
  netem: add 64bit rates support

 tc/q_netem.c | 29 ++++++++++++++++++++++++-----
 tc/q_tbf.c   |  2 ++
 2 files changed, 26 insertions(+), 5 deletions(-)

-- 
1.8.0
