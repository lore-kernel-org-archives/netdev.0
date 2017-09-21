From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 0/2] add device MTU validation check
Date: Thu, 21 Sep 2017 21:32:00 +0800
Message-ID: <1506000722-40095-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, willemb@google.com,
        stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:15993 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbdIUNcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 09:32:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch serial add device MTU validation check, so that only valid mtu value 
can be set when adding new device.

Zhang Shengju (2):
  dummy: add device MTU validation check
  ifb: add device MTU validation check

 drivers/net/dummy.c | 8 ++++++++
 drivers/net/ifb.c   | 8 ++++++++
 2 files changed, 16 insertions(+)

-- 
1.8.3.1
