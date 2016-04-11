From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 v2 0/3] bridge: filtering by vlan id
Date: Mon, 11 Apr 2016 17:45:13 +0200
Message-ID: <1460389516-1643-1-git-send-email-nikolay@cumulusnetworks.com>
References: <570BC2FD.8010201@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37604 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbcDKPpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 11:45:23 -0400
Received: by mail-wm0-f49.google.com with SMTP id n3so110445178wmn.0
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 08:45:23 -0700 (PDT)
In-Reply-To: <570BC2FD.8010201@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This set adds support for filtering by a vlan id when showing fdb/mdb/vlan
entries. Currently the filtering is implemented entirely in user-space, but
the plan is to add kernel support as well. The vlan show part is also needed
for the future per-vlan statistics in order to be able to show them only for
a specific vlan. I plan to update the bridge man page soon as it's missing
other options too and it seemed inconsistent to add this given that there're
potential paragraphs missing, thus I'll post a separate patch for that.

v2: in patch 03 print only the ports having the vlan instead of empty
"vlan ids" column

Thank you,
 Nik


Nikolay Aleksandrov (3):
  bridge: fdb: add support to filter by vlan id
  bridge: mdb: add support to filter by vlan id
  bridge: vlan: add support to filter by vlan id

 bridge/fdb.c  | 21 +++++++++++++++------
 bridge/mdb.c  | 11 +++++++++--
 bridge/vlan.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++++----------
 3 files changed, 74 insertions(+), 18 deletions(-)

-- 
2.4.3
