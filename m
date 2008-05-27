From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bnx2i: Add bnx2i iSCSI driver.
Date: Tue, 27 May 2008 12:52:47 -0700 (PDT)
Message-ID: <20080527.125247.73979652.davem@davemloft.net>
References: <ada8wy07osq.fsf@cisco.com>
	<1211578969.26900.5.camel@dhcp-10-13-110-217.broadcom.com>
	<adave0z24o4.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anilgv@broadcom.com, mchan@broadcom.com, michaelc@cs.wisc.edu,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59866
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756060AbYE0Twv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 15:52:51 -0400
In-Reply-To: <adave0z24o4.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 27 May 2008 07:38:19 -0700

> So you are creating sockets just to reserve TCP ports to avoid host
> stack clashes with your offload engine?  Wasn't this approach strongly
> rejected (in the context of iWARP) in the past?

Yes, it was, and likewise similar hacks in other areas will
be rejected similarly.

