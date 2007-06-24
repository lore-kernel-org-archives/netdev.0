From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: DCCP: 2.6.22-rc5-git8 compile warning
Date: Sun, 24 Jun 2007 22:02:38 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0706242200130.11964@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:5227 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbXFXUCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 16:02:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



git tree a06381fec77bf88ec6c5eb6324457cb04e9ffd69 (last commit ID) 
gives:

/ws/linux-2.6.22/net/dccp/ipv4.c:589: warning: initialization from 
incompatible
/ws/linux-2.6.22/net/dccp/ipv6.c:387: warning: initialization from 
incompatible
[pointer type - `less` cut it off from the 80 col screen]

Offending lines, ipv4.c:
        .send_ack       = dccp_reqsk_send_ack,

ipv6.c:
        .send_ack       = dccp_reqsk_send_ack,

These could be fixed :)


	Jan
-- 
