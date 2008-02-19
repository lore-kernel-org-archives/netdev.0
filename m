From: "Reither Robert" <Robert.Reither@av-digital.at>
Subject: AW: AW: Problem receiving multicast with kernel.2.6.24 #3
Date: Tue, 19 Feb 2008 14:57:08 +0100
Message-ID: <BA41E8A07B73A041948C2E3A4EF6239D062F1A@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av-digital.at ([88.116.237.238]:25896 "EHLO
	av-digital-exch.avdigital.at" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752230AbYBSN5L convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 08:57:11 -0500
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Visit AVD on prolight+sound in Frankfurt from 12.-15. March 2008 - Hall 8.0, Stand G16
________________________________________________________________________



OK, found one solution (but i think, this should not the normal way)

MC joining first the VLAN device (eth0.3) and than the physical (eth0) does the trick, 100% success ...

Doing it the opposite way, gives the same problem as before ...

So somehow joining the VLAN interface disrupts the join to the physical one ...

Ideas ?

Robert
