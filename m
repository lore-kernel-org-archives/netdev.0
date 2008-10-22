From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] bonding: update docs to correctly reflect arp_ip_target
	behavior
Date: Wed, 22 Oct 2008 16:08:34 -0400
Message-ID: <20081022200639.GA10873@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33886 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944AbYJVUIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 16:08:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The latest version of Red Hat Enterprise Linux 5 doesn't need '+' in
front of each IP address listed as an arp_ip_target, and correctly
supports a comma separated list of IP addresses using the current
version of initscripts.  This patch drops all references to the need for
a '+' before each IP address and the description now matches the
behavior.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---

 bonding.txt |   13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 688dfe1..17f2803 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -926,19 +926,10 @@ NETMASK, NETWORK and BROADCAST) to match your network configuration.
 indeed, preferable, to specify the bonding options in the ifcfg-bond0
 file, e.g. a line of the format:
 
-BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=+192.168.1.254"
+BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254"
 
 	will configure the bond with the specified options.  The options
-specified in BONDING_OPTS are identical to the bonding module parameters
-except for the arp_ip_target field.  Each target should be included as a
-separate option and should be preceded by a '+' to indicate it should be
-added to the list of queried targets, e.g.,
-
-	arp_ip_target=+192.168.1.1 arp_ip_target=+192.168.1.2
-
-	is the proper syntax to specify multiple targets.  When specifying
-options via BONDING_OPTS, it is not necessary to edit /etc/modules.conf or
-/etc/modprobe.conf.
+specified in BONDING_OPTS are identical to the bonding module parameters.
 
 	For older versions of initscripts that do not support
 BONDING_OPTS, it is necessary to edit /etc/modules.conf (or
