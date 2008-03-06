From: Jonas Bonn <jonas@southpole.se>
Subject: struct pci_device_id declaration cleanups
Date: Thu,  6 Mar 2008 11:55:38 +0100
Message-ID: <1204800947-21569-1-git-send-email-jonas@southpole.se>
To: jonas@southpole.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:44090 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760504AbYCFKzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 05:55:49 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id DC0894ED0F8
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 11:55:47 +0100 (CET)
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This set of patches applies the macro DECLARE_PCI_DEVICE_TABLE to the 
declarations of struct pci_device_id in several network drivers.  The drivers
build cleanly with these patches (without any new warnings) on both x86 and 
PowerPC.

There are ~90 such cleanups in the /drivers/net tree alone (and ~350 in the
kernel overall); these patches are just a subset to avoid flooding the mailing 
list before getting feedback.

These 9 patches can also be pulled from the "net" branch of:

git://www.southpole.se/~jonas/git/linux.git

The remainder of the cleanups will be pushed out to my public tree once I 
know the reaction to this subset.

The diffstat for this subset is:

 drivers/net/cassini.c                |    2 +-
 drivers/net/e1000/e1000_main.c       |    2 +-
 drivers/net/e1000e/netdev.c          |    2 +-
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 drivers/net/wan/farsync.c            |    2 +-
 drivers/net/wan/pc300_drv.c          |    2 +-
 drivers/net/wan/pc300too.c           |    2 +-
 drivers/net/wan/pci200syn.c          |    2 +-
 drivers/net/wan/wanxl.c              |    2 +-
 9 files changed, 9 insertions(+), 9 deletions(-)

/Jonas

