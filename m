From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/4] s390: qeth fixes 2.6.29
Date: Mon, 15 Dec 2008 00:46:07 -0800 (PST)
Message-ID: <20081215.004607.228873135.davem@davemloft.net>
References: <20081211132309.053505000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47797
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752223AbYLOIqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 03:46:05 -0500
In-Reply-To: <20081211132309.053505000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Thu, 11 Dec 2008 14:23:09 +0100

> here are some fixes for 2.6.29
> The patches apply to linux-next

They do not apply to net-next-2.6, as just one example patch #2 has
part of the patch saying:

@@ -1207,12 +1207,9 @@ static int qeth_l3_start_ipa_source_mac(
 
 	QETH_DBF_TEXT(TRACE, 3, "stsrcmac");
 
-	if (!card->options.fake_ll)
-		return -EOPNOTSUPP;
-
 	if (!qeth_is_supported(card, IPA_SOURCE_MAC)) {
 		dev_info(&card->gdev->dev,
-			"Inbound source address not supported on %s\n",
+			"Inbound source MAC-address not supported on %s\n",
 			QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}

Yet that "dev_info" is a PRINT_INFO in the net-next-2.6 tree.

Please resend patches which apply cleanly to my tree and I'll apply
them.

Thank you.
