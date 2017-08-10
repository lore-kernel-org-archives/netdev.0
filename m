From: Kalle Valo <kvalo@codeaurora.org>
Subject: Regression: Bug 196547 - Since 4.12 - bonding module not working with wireless drivers
Date: Thu, 10 Aug 2017 08:39:20 +0300
Message-ID: <87shh0gewn.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, James Feeney <james@nurealm.net>
To: Mahesh Bandewar <maheshb@google.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37636 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751346AbdHJFjZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:39:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mahesh and Andy,

James Feeney reported that there's a serious regression in bonding
module since v4.12, it doesn't work with wireless drivers anymore as
wireless drivers don't report the link speed via ethtool:

https://bugzilla.kernel.org/show_bug.cgi?id=196547

In the bug report it's said that this commit is the culprit:

3f3c278c94dd bonding: fix active-backup transition

Is there a fix for this or should that commit be reverted? This seems to
be a serious regression as there are multiple reports already and we
should get it fixed for v4.13, and the fix backported to v4.12 stable
release.

-- 
Kalle Valo
