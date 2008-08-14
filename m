From: Daniel Ng <daniel_ng11@lycos.com>
Subject: Re: Multicast socket behaviour?
Date: Thu, 14 Aug 2008 00:08:58 +0000 (UTC)
Message-ID: <loom.20080814T000653-690@post.gmane.org>
References: <loom.20080813T082132-707@post.gmane.org> <OFB63F1889.F6ECCEEF-ON882574A4.0056055F-882574A4.00590247@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:41267 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752865AbYHNAJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 20:09:24 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1KTQOq-00052y-53
	for netdev@vger.kernel.org; Thu, 14 Aug 2008 00:09:19 +0000
Received: from CPE-124-190-96-129.vic.bigpond.net.au ([124.190.96.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 00:09:08 +0000
Received: from daniel_ng11 by CPE-124-190-96-129.vic.bigpond.net.au with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 00:09:08 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens <dlstevens <at> us.ibm.com> writes:
> it usually doesn't make sense for an app in a single multicast
> routing domain to want to join on multiple interfaces

Now, what if I have a linear network of say 3 Linux boxes, connected together 
simply:

A----PPP0-------B-----PPP1------C

All machines are DVMRP multicast routers.

In order for B to hear the multicast packets originated from both A and C, 
wouldn't B need to join the DVMRP multicast group on *both* its PPP interfaces?

If so, then can this be done with a single socket? How?

Daniel

