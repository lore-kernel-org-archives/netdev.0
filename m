From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 0/3] wimax: Kbuild / rfkill-build fixes (v2)
Date: Wed,  7 Jan 2009 09:18:44 -0800
Message-ID: <cover.1231348339.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wimax@linuxwimax.org, greg@kroah.com,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-wimax@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:44712 "EHLO gocho"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753685AbZAGRS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 12:18:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These three patches fix issues reported by Randy Dunlap on the
linux-next tree for Jan 6:

http://lkml.org/lkml/2009/1/6/340

The issue fixed by patch #3 wasn't reported on the emails but was
uncovered while discussing the fixes.

This applies to the wimax tree kept in gregkh's repository:

http://kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/gregkh-04-u=
sb/

Changes in v2

- fixed silly one-char typo #ifndef CONFIG_BUG vs #ifdef CONFIG_BUG
  reported by Ilpo J=C3=A4rvinen=20

Inaky Perez-Gonzalez (3):
  wimax: fix '#ifndef CONFIG_BUG' layout to avoid warning
  wimax: fix kconfig interactions with rfkill and input layers
  wimax: testing for rfkill support should also test for
    CONFIG_RFKILL_MODULE

 net/wimax/Kconfig     |   14 ++++++++++++++
 net/wimax/id-table.c  |    8 +++++---
 net/wimax/op-rfkill.c |    2 +-
 3 files changed, 20 insertions(+), 4 deletions(-)

