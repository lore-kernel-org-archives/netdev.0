From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 1/2] ethtool: fix manpage so that it will display
	tables again
Date: Fri, 08 Apr 2011 15:12:34 -0700
Message-ID: <20110408221234.26893.58812.stgit@gitlad.jf.intel.com>
References: <20110408221135.26893.50092.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37926 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757785Ab1DHWMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 18:12:35 -0400
In-Reply-To: <20110408221135.26893.50092.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current ethtool manpage is not displaying tables.  After trying to pass
the manpage through tbl I repeatedly saw the error:
tbl:ethtool.8.in:707: unrecognised format `x'
tbl:ethtool.8.in:707: giving up on this table

By dropping the 'x' the errors went away and when I built the manpage the
tables reappeared so I am assuming this is the correct approach.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool.8.in |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index ed24d4c..714486e 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -540,7 +540,7 @@ names the type of message to enable or disable; \fIN\fR specifies the
 new flags numerically. The defined type names and numbers are:
 .TS
 nokeep;
-lB	l	lx.
+lB	l	l.
 drv	0x0001  General driver status
 probe	0x0002  Hardware probing
 link	0x0004  Link state
@@ -569,7 +569,7 @@ Retrieves the receive network flow classification configurations.
 Retrieves the hash options for the specified network traffic type.
 .TS
 nokeep;
-lB	lx.
+lB	l.
 tcp4	TCP over IPv4
 udp4	UDP over IPv4
 ah4	IPSEC AH/ESP over IPv4
@@ -587,7 +587,7 @@ Configures the receive network flow classification.
 Configures the hash options for the specified network traffic type.
 .TS
 nokeep;
-lB	lx.
+lB	l.
 m	Hash on the Layer 2 destination address of the rx packet.
 v	Hash on the VLAN tag of the rx packet.
 t	Hash on the Layer 3 protocol field of the rx packet.
@@ -637,7 +637,7 @@ Configure Rx ntuple filters and actions
 .B flow\-type tcp4|udp4|sctp4|ether
 .TS
 nokeep;
-lB	lx.
+lB	l.
 tcp4	TCP over IPv4
 udp4	UDP over IPv4
 sctp4	SCTP over IPv4
@@ -704,7 +704,7 @@ Specify a mask for the user-specific data.
 Specifies the Rx queue to send packets to, or some other action.
 .TS
 nokeep;
-lB	lx.
+lB	l.
 -2	Clear the filter
 -1	Drop the matched flow
 0 or higher	Rx queue to route the flow

