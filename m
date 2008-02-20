From: Jonas Bonn <jonas@southpole.se>
Subject: pci_device_id cleanups
Date: Wed, 20 Feb 2008 13:53:36 +0100
Message-ID: <1203512031-14318-1-git-send-email-jonas@southpole.se>
Cc: greg@kroah.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:42366 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756762AbYBTMxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 07:53:53 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id 3069F4ED107
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 13:53:52 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The PCI_DEVICE_TABLE patch I sent earlier doesn't necessarily make much sense by itself... here is a set of patches that apply this macro, in turn moving a lot of this data into __devinitconst which is discardable in certain situations.  Hopefully the benefit of this approach is a bit clearer now.

 drivers/net/3c59x.c               |    2 +-
 drivers/net/amd8111e.c            |    2 +-
 drivers/net/arcnet/com20020-pci.c |    2 +-
 drivers/net/defxx.c               |    2 +-
 drivers/net/hamachi.c             |    2 +-
 drivers/net/niu.c                 |    2 +-
 drivers/net/pasemi_mac.c          |    2 +-
 drivers/net/sk98lin/skge.c        |    2 +-
 drivers/net/skfp/skfddi.c         |    2 +-
 drivers/net/starfire.c            |    2 +-
 drivers/net/sunhme.c              |    2 +-
 drivers/net/tlan.c                |    2 +-
 drivers/net/wan/dscc4.c           |    2 +-
 drivers/net/wan/lmc/lmc_main.c    |    2 +-
 include/linux/pci.h               |    9 +++++++++
 15 files changed, 23 insertions(+), 14 deletions(-)


