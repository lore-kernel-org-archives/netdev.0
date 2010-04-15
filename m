From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 0/3]: fixes for multicast routing rules
Date: Thu, 15 Apr 2010 14:47:55 +0200
Message-ID: <1271335678-20961-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63173 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab0DOMsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 08:48:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the following three patches fix a few bugs introduced by the multicast routing
rule patches:

- a missing Kconfig dependency on IP_MROUTE

- a bug introduced by the list conversion, causing the list head to be treated
  as an element

- a NULL pointer dereference: the net pointer in ipmr_destroy_unres() was
  initialized to NULL. This patch was actually intended to be folded into
  the patch introducing multicast routing rules, but I missed it when
  rebasing to the current tree.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/ipmr-2.6.git master

Thanks!
