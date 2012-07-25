From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC ETHTOOL PATCH 0/2] implement MDI-X set
Date: Wed, 25 Jul 2012 10:52:57 -0700
Message-ID: <20120725174351.9839.132.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com
To: netdev@vger.kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45999 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751445Ab2GYUwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 16:52:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some users reported issues connecting to some switches, where
they were unable to get link (see kernel.org bugzilla 11998)

This patch series improves ethtool to support controlling the
MDI/MDI-X state of a link.  It also adds support to the "get
settings" function to show if the MDI state was forced or not.

This is currently RFC because internal testing was not completed
but I am sending the patch to make sure the design is good.

Special thanks to Ben Hutchings for his input to this series.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

---

Jesse Brandeburg (2):
      ethtool: allow setting MDI-X state
      ethtool.h: implement new MDI-X set defines


 ethtool-copy.h |   17 +++++++++++------
 ethtool.8.in   |    8 ++++++++
 ethtool.c      |   48 +++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 64 insertions(+), 9 deletions(-)

-- 
Jesse Brandeburg
