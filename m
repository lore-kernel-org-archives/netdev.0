From: Pawel Foremski <pjf@asn.pl>
Subject: Re: [PATCH 6/7] bonding: Add priv_flag to avoid event mishandling
Date: Mon, 04 Sep 2006 10:12:24 +0200
Message-ID: <edgn1t$nrh$1@sea.gmane.org>
References: <200609012213.k81MDJZt008128@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:45458 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S932494AbWIDIPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 04:15:04 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GK9bh-0006WU-Q0
	for netdev@vger.kernel.org; Mon, 04 Sep 2006 10:15:01 +0200
Received: from demiurg.asn.pl ([85.14.84.18])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2006 10:15:01 +0200
Received: from pjf by demiurg.asn.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2006 10:15:01 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Add priv_flag to specifically identify bonding-involved devices.  Needed
> because IFF_MASTER is an unreliable identifier (vlan interfaces above
> bonding will inherit IFF_MASTER).  Misidentification of devices would 
> cause notifier events for other devices to be erroneously processed by 
> bonding, causing various havoc.

Just wanted to report that this patch solves a kernel oops on 2.6.17.11
while trying to change name of a VLAN device created on top of a bonding
one.

Thanks,

-- 
Pawel Foremski  
pjf@asn.pl


-- 
VGER BF report: U 0.687767
