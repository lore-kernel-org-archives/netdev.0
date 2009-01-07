From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 0/3] wimax: Kbuild / rfkill-build fixes
Date: Tue,  6 Jan 2009 23:58:19 -0800
Message-ID: <cover.1231314782.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:42319 "EHLO gocho"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752834AbZAGH60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 02:58:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These three patches fix issues reported by Randy Dunlap on the
linux-next tree for Jan 6:

http://lkml.org/lkml/2009/1/6/340

The issue fixed by patch #3 wasn't reported on the emails but was
uncovered while discussing the fixes.

Inaky Perez-Gonzalez (3):
  wimax: fix '#ifdef CONFIG_BUG' layout to avoid warning
  wimax: fix kconfig interactions with rfkill and input layers
  wimax: testing for rfkill support should also test for
    CONFIG_RFKILL_MODULE

 net/wimax/Kconfig     |   14 ++++++++++++++
 net/wimax/id-table.c  |   10 ++++++----
 net/wimax/op-rfkill.c |    2 +-
 3 files changed, 21 insertions(+), 5 deletions(-)

