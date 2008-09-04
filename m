From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: [PATCH 0/3] Various fixes and additions for PowerPC 405EZ
Date: Thu, 4 Sep 2008 11:01:25 -0400
Message-ID: <20080904150125.GA2479@yoda.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:45673 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136AbYIDPCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 11:02:19 -0400
Received: by wa-out-1112.google.com with SMTP id j37so2316416waf.23
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2008 08:02:19 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch series adds things needed to support the
PowerPC 405EZ SoC.  I'm mostly sending these out now for review
and feedback, since I'll need to get these fixed up before I can
send out the Acadia board port patches.

The first patch should be good as-is.  The second two might need a
bit of rework, depending on various things.

josh

Josh Boyer (3):
  ibm_newemac: Allow the "no flow control" EMAC feature to work
  ibm_newemac: Introduce mal_has_feature
  ibm_newemac: MAL support for PowerPC 405EZ

 drivers/net/ibm_newemac/Kconfig |   12 +++++
 drivers/net/ibm_newemac/core.c  |    2 +
 drivers/net/ibm_newemac/core.h  |    3 +
 drivers/net/ibm_newemac/mal.c   |   98 +++++++++++++++++++++++++++++++--------
 drivers/net/ibm_newemac/mal.h   |   37 +++++++++++++++
 5 files changed, 132 insertions(+), 20 deletions(-)
