From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 0/2] iproute2: bridge vlan range support
Date: Sun, 25 Jan 2015 18:26:23 -0800
Message-ID: <1422239185-14054-1-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:37867 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbbAZC0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 21:26:32 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so8999240pad.1
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 18:26:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series adds support for vlan ranges in iproute2 bridge add
and show commands.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

Roopa Prabhu (2):
  iproute2: bridge: support vlan range for adds
  iproute2: bridge vlan show new option to print ranges

 bridge/br_common.h        |    1 +
 bridge/bridge.c           |    6 ++++-
 bridge/vlan.c             |   55 ++++++++++++++++++++++++++++++++++++++++-----
 include/linux/if_bridge.h |    2 ++
 include/linux/rtnetlink.h |    1 +
 5 files changed, 58 insertions(+), 7 deletions(-)

-- 
1.7.10.4
