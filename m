From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/3] ethtool.spec: Update summary and description,
 based on Fedora package
Date: Tue, 17 Jul 2012 17:23:45 +0100
Message-ID: <1342542225.2698.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342542068.2698.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31909 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751664Ab2GQQXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 12:23:49 -0400
In-Reply-To: <1342542068.2698.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
It would probably be better to come up with a single concise description
to use in all the various places it's needed: RPMs, debs, web site,
manual page...

Ben.

 ethtool.spec.in |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/ethtool.spec.in b/ethtool.spec.in
index 4ff736a..879555d 100644
--- a/ethtool.spec.in
+++ b/ethtool.spec.in
@@ -3,7 +3,7 @@ Version		: @VERSION@
 Release		: 1
 Group		: Utilities
 
-Summary		: A tool for setting ethernet parameters
+Summary		: Settings tool for Ethernet and other network devices
 
 License		: GPL
 URL		: http://sourceforge.net/projects/gkernel/
@@ -13,11 +13,9 @@ Source		: %{name}-%{version}.tar.gz
 

 %description
-Ethtool is a small utility to get and set values from your your ethernet 
-controllers.  Not all ethernet drivers support ethtool, but it is getting 
-better.  If your ethernet driver doesn't support it, ask the maintainer to 
-write support - it's not hard!
-
+This utility allows querying and changing settings such as speed,
+port, auto-negotiation, PCI locations and checksum offload on many
+network devices, especially Ethernet devices.
 
 %prep
 %setup -q
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
