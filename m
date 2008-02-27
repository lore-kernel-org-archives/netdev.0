From: Pavel Krauz <krauz@cncz.cz>
Subject: capturing vlan on 2.6.18
Date: Wed, 27 Feb 2008 15:17:51 +0100
Message-ID: <200802271517.52092.krauz@cncz.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kwall.cncz.cz ([194.213.192.9]:14070 "EHLO kwall.cncz.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753954AbYB0O0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 09:26:00 -0500
Received: from asterix.domain.local (unknown [10.3.1.3])
	by kwall.cncz.cz (Postfix) with ESMTP id 0B314BA5D0
	for <netdev@vger.kernel.org>; Wed, 27 Feb 2008 15:18:00 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello 
I am running Centos 5.0 with kernel 2.6.18-8.el5 and I have the following problem with tcpdump and VLAN.
When I replay the traffic that contains VLAN I do not see VLAN headers with tcpdump - they are removed
and I cannot filter for example on VLAN id.
My program which uses PCAP also does not see the VLAN headers, and cannot filter on them!

When I replay locally to the same interface (not from different machine) I see VLAN without problems. When
I replay from different machine I do not see VLAN!

The 2.4.20 kernel works as expected - shows VLAN headers.

Is this a kernel bug or am I supposed to set something?
Thanks & best regards
Pavel Krauz

