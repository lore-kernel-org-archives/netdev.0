From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next 0/2] (Shortened) Bonding patch series
Date: Mon, 23 Feb 2015 17:49:57 -0800
Message-ID: <1424742597-6489-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:46757 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbbBXBuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 20:50:11 -0500
Received: by mail-ig0-f201.google.com with SMTP id b16so5784695igk.0
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 17:50:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm shortening the earlier patch series to just two patches at this moment.
Andy is going to integrate remaining 3 patches with his netlink changes
and post the completed patches.

These two patches are the same one from the previous patch series with 
some styling changes (Dave Miller's suggestions) for the churn-machine patch.

Mahesh Bandewar (2):
  bonding: Verify RX LACPDU has proper dest mac-addr
  bonding: Implement port churn-machine (AD standard 43.4.17).

 drivers/net/bonding/bond_3ad.c    | 60 +++++++++++++++++++++++++++++++++++++--
 drivers/net/bonding/bond_procfs.c | 43 ++++++++++++++++++++++++----
 include/net/bond_3ad.h            | 29 +++++++++++++++++++
 3 files changed, 125 insertions(+), 7 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
