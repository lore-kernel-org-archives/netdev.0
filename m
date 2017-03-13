From: Tommi Rantala <tommi.t.rantala@nokia.com>
Subject: "tipc: fix socket timer deadlock" to stable?
Date: Mon, 13 Mar 2017 12:42:50 +0200
Message-ID: <42aebc97-bd71-a9f8-490b-42d8e81283c6@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, GUNA <gbalasun@gmail.com>,
        Ying Xue <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>, Jon Paul Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50127.outbound.protection.outlook.com ([40.107.5.127]:3904
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751521AbdCMKm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 06:42:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We're seeing this tipc deadlock in 4.4.y, that was fixed in the mainline 
commit f1d048f24e66ba85d3dabf3d076cefa5f2b546b0 "tipc: fix socket timer 
deadlock".

Could/should this patch also be included in the stable kernel trees?

I just checked that the patch applies on top of 4.4.53, only the line 
numbers are different compared to the upstream commit.

-Tommi
