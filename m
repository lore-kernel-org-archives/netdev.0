From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 0/3] iproute: fix tc ipt/xt module.
Date: Wed, 2 Dec 2009 16:10:37 +0100
Message-ID: <cover.1259765732.git.andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy2.bredband.net ([195.54.101.72]:55989 "EHLO
	proxy2.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158AbZLBPJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 10:09:48 -0500
Received: from ipb1.telenor.se (195.54.127.164) by proxy2.bredband.net (7.3.140.3)
        id 4AD3E1BC0168646C for netdev@vger.kernel.org; Wed, 2 Dec 2009 16:09:53 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xtables API has changed since the tc xt module was written.
This mini-series moves the legacy stuff out of the way (kept for
compatibility with older iptables versions) and starts
a new fresh xt module.

Hopefully the xtables api will be kept stable in the future.
If so, this new xt module should continue working since it only
uses exposed functions (unlike the old one which had an internal
header to access internal functions in xtables).

Andreas Henriksson (3):
  Keep the old tc/ipt/xt module for compatibility.
  Add new (iptables 1.4.5 compatible) tc/ipt/xt module.
  Slightly improve the configure script.

 configure     |   93 ++++++++++--
 tc/Makefile   |   13 ++-
 tc/m_xt.c     |  161 +++++----------------
 tc/m_xt_old.c |  433 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 557 insertions(+), 143 deletions(-)
 create mode 100644 tc/m_xt_old.c

