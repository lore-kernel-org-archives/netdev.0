From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 3/3] ethtool.spec: Do not include ChangeLog or
 INSTALL
Date: Tue, 17 Jul 2012 17:24:19 +0100
Message-ID: <1342542259.2698.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342542068.2698.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31925 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751944Ab2GQQYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 12:24:22 -0400
In-Reply-To: <1342542068.2698.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ChangeLog is ancient history, replaced by the version control
changelog.

INSTALL is redundant in a binary package.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.spec.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ethtool.spec.in b/ethtool.spec.in
index 863dfd4..6e9e1f5 100644
--- a/ethtool.spec.in
+++ b/ethtool.spec.in
@@ -34,7 +34,7 @@ make install DESTDIR=${RPM_BUILD_ROOT}
 %defattr(-,root,root)
 /usr/sbin/ethtool
 %{_mandir}/man8/ethtool.8*
-%doc AUTHORS COPYING INSTALL NEWS README ChangeLog
+%doc AUTHORS COPYING NEWS README
 

 %changelog
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
