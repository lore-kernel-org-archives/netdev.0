From: frank.blaschka@de.ibm.com
Subject: [patch 4/6] [PATCH] qeth: Clarify card type naming for virtual NICs
Date: Mon, 19 Nov 2012 13:46:48 +0100
Message-ID: <20121119124659.721024655@de.ibm.com>
References: <20121119124644.679089322@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:42091 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778Ab2KSMrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 07:47:05 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 19 Nov 2012 12:47:03 -0000
Content-Disposition: inline; filename=603-qeth-card-naming.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

So far, virtual NICs whether attached to a VSWITCH or a guest LAN were always
displayed as guest LANs in the device driver attributes and messages, while
in fact it is a virtual NIC.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -73,13 +73,13 @@ static inline const char *qeth_get_cardn
 	if (card->info.guestlan) {
 		switch (card->info.type) {
 		case QETH_CARD_TYPE_OSD:
-			return " Guest LAN QDIO";
+			return " Virtual NIC QDIO";
 		case QETH_CARD_TYPE_IQD:
-			return " Guest LAN Hiper";
+			return " Virtual NIC Hiper";
 		case QETH_CARD_TYPE_OSM:
-			return " Guest LAN QDIO - OSM";
+			return " Virtual NIC QDIO - OSM";
 		case QETH_CARD_TYPE_OSX:
-			return " Guest LAN QDIO - OSX";
+			return " Virtual NIC QDIO - OSX";
 		default:
 			return " unknown";
 		}
@@ -108,13 +108,13 @@ const char *qeth_get_cardname_short(stru
 	if (card->info.guestlan) {
 		switch (card->info.type) {
 		case QETH_CARD_TYPE_OSD:
-			return "GuestLAN QDIO";
+			return "Virt.NIC QDIO";
 		case QETH_CARD_TYPE_IQD:
-			return "GuestLAN Hiper";
+			return "Virt.NIC Hiper";
 		case QETH_CARD_TYPE_OSM:
-			return "GuestLAN OSM";
+			return "Virt.NIC OSM";
 		case QETH_CARD_TYPE_OSX:
-			return "GuestLAN OSX";
+			return "Virt.NIC OSX";
 		default:
 			return "unknown";
 		}
