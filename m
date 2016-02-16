From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/2] bridge: mdb: add support for extended attributes
Date: Tue, 16 Feb 2016 12:46:52 +0100
Message-ID: <1455623214-2951-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37998 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbcBPLrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 06:47:35 -0500
Received: by mail-wm0-f47.google.com with SMTP id a4so95815843wme.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 03:47:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
This small set allows to extend the per mdb entry exported attributes,
before this set we had only a structure exported which couldn't be changed
because we would've broken user-space, after this we extend the attribute
that was used for the structure and add per-mdb entry attributes after the
struct has been added (see patch 02 for more details). Note that the reason
we can't simply add an attribute after MDBA_MDB_ENTRY_INFO is that current
users (e.g. iproute2) walk over the attribute list directly without
checking for the attribute type.
Patch 01 is a simple change to reduce one indentation level in order to
avoid over 80 char lines.

Cheers,
 Nik

Nikolay Aleksandrov (2):
  bridge: mdb: reduce the indentation level in br_mdb_fill_info
  bridge: mdb: add support for more attributes and export timer

 include/uapi/linux/if_bridge.h | 13 +++++++++++-
 net/bridge/br_mdb.c            | 47 ++++++++++++++++++++++++++++--------------
 2 files changed, 43 insertions(+), 17 deletions(-)

-- 
2.4.3
