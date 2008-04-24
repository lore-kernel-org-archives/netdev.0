From: frank.blaschka@de.ibm.com
Subject: [patch 00/11] s390: network device driver fixes for 2.6.26
Date: Thu, 24 Apr 2008 10:15:17 +0200
Message-ID: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:59181 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbYDXITD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

here are some s390 network device driver fixes for 2.6.26

Klaus Wacker (1)
lcs: CCL-sequ. numbers required for protocol 802.2 only.

Ursula Braun (3)
netiucv: get rid of in_atomic() use
qeth/cu3088/ccwgroup: Unify parsing for group attribute.
qeth: read number of ports from card

Peter Tiedemann (1)
qeth: module size reduction.

Frank Blaschka (5)
qeth: layer 3 support vlan IPv6 on hiper socket
qeth: provide get ethtool settings
qeth: rework fast path
qeth: layer 3 add missing dev_open/close to ccwgroup handler
qeth: layer 2 allow ethtool to set TSO

Cornelia Huck (1)
netiucv: Fix missing driver attributes.

Thanks,
        Frank

-- 
