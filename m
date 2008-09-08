From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: [PATCH 0/3 v2] ibm_newemac: Various fixes and additions for
	PPC405EZ
Date: Mon, 8 Sep 2008 08:44:59 -0400
Message-ID: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:41688 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbYIHNEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 09:04:55 -0400
Received: by gxk9 with SMTP id 9so7667305gxk.13
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 06:04:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch series adds things needed to support the PowerPC 405EZ
SoC.  I've incorporated the suggestions and fixes from the previous round
of patches and barring any further comments these should be ready to go.

josh

Josh Boyer (3):
  ibm_newemac: Allow the "no flow control" EMAC feature to work
  ibm_newemac: Introduce mal_has_feature
  ibm_newemac: MAL support for PowerPC 405EZ

 arch/powerpc/include/asm/dcr-regs.h |    7 ++++
 drivers/net/ibm_newemac/Kconfig     |   12 +++++++
 drivers/net/ibm_newemac/core.c      |    2 +
 drivers/net/ibm_newemac/core.h      |    3 ++
 drivers/net/ibm_newemac/mal.c       |   60 ++++++++++++++++++++++++++++++++---
 drivers/net/ibm_newemac/mal.h       |   34 ++++++++++++++++++++
 6 files changed, 113 insertions(+), 5 deletions(-)

