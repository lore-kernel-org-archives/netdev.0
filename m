From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 0/3] bridge: filtering by vlan id
Date: Mon, 11 Apr 2016 15:18:27 +0200
Message-ID: <1460380710-29583-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38840 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143AbcDKNTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 09:19:45 -0400
Received: by mail-wm0-f52.google.com with SMTP id u206so104036751wme.1
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 06:19:44 -0700 (PDT)
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

Thank you,
 Nik

Nikolay Aleksandrov (3):
  bridge: fdb: add support to filter by vlan id
  bridge: mdb: add support to filter by vlan id
  bridge: vlan: add support to filter by vlan id

 bridge/fdb.c  | 21 ++++++++++++++------
 bridge/mdb.c  | 11 +++++++++--
 bridge/vlan.c | 63 +++++++++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 75 insertions(+), 20 deletions(-)

-- 
2.4.3
