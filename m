From: "Reither Robert" <Robert.Reither@av-digital.at>
Subject: AW: Problem receiving multicast/promiscuous-mode with kernel.2.6.24
Date: Mon, 11 Feb 2008 16:46:13 +0100
Message-ID: <BA41E8A07B73A041948C2E3A4EF6239D062F0D@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av-digital.at ([88.116.237.238]:29569 "EHLO
	av-digital-exch.avdigital.at" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753438AbYBKPqx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 10:46:53 -0500
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Visit AVD on prolight+sound in Frankfurt from 12.-15. March 2008 - Hall 8.0, Stand G16
________________________________________________________________________




OK, after some more testing, things become clearer ...

joining eth0.3 gives this strange unreliable behaviour...

Joining eth0 , and i can see the packets always floating in with tcpdump -p -i eth0.3 (or -i eth0)

But my application won't get the packets !!!

Maybe this is because i'm using pselect() to wait for incoming packets ?????

Question: Should it possible to join on a VLAN device ? Or is this something bad ???

Robert
