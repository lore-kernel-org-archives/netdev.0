From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH ethtool 0/2] Add new receive timestamping filter
Date: Tue, 23 May 2017 16:29:28 +0200
Message-ID: <20170523142930.28181-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        "John W . Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49364 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936592AbdEWO3f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 10:29:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches update ethtool to be able to print the new NTP
timestamping filter in the ethtool -T command.

Miroslav Lichvar (2):
  net_tstamp.h: sync with net-next
  ethtool: add support for HWTSTAMP_FILTER_NTP_ALL

 ethtool.c         |  3 ++-
 net_tstamp-copy.h | 52 +++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 43 insertions(+), 12 deletions(-)

-- 
2.9.3
