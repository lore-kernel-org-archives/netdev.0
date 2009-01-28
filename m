From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: update documentation ip aliases
Date: Wed, 28 Jan 2009 08:20:30 -0800
Message-ID: <20090128082030.1b166262@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46438 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbZA1QUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2009 11:20:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This documentation is old.  Add a short note to describe why aliases
are no long necessary, and remove the old contact/edit info.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/Documentation/networking/alias.txt	2009-01-28 08:13:26.103682808 -0800
+++ b/Documentation/networking/alias.txt	2009-01-28 08:18:03.624759404 -0800
@@ -2,13 +2,13 @@
 IP-Aliasing:
 ============
 
-IP-aliases are additional IP-addresses/masks hooked up to a base 
-interface by adding a colon and a string when running ifconfig. 
-This string is usually numeric, but this is not a must.
-
-IP-Aliases are avail if CONFIG_INET (`standard' IPv4 networking) 
-is configured in the kernel.
+IP-aliases are an obsolete way to manage multiple IP-addresses/masks
+per interface. Newer tools such as iproute2 support multiple
+address/prefixes per interface, but aliases are still supported
+for backwards compatibility.
 
+An alias is formed by adding a colon and a string when running ifconfig.
+This string is usually numeric, but this is not a must.
 
 o Alias creation.
   Alias creation is done by 'magic' interface naming: eg. to create a
@@ -38,16 +38,3 @@ o Relationship with main device
 
   If the base device is shut down the added aliases will be deleted 
   too.
-
-
-Contact
--------
-Please finger or e-mail me:
-   Juan Jose Ciarlante <jjciarla@raiz.uncu.edu.ar>
-
-Updated by Erik Schoenfelder <schoenfr@gaertner.DE>
-
-; local variables:
-; mode: indented-text
-; mode: auto-fill
-; end:
