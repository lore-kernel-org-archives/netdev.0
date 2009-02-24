From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netxen: fix physical port mapping
Date: Tue, 24 Feb 2009 03:44:30 -0800 (PST)
Message-ID: <20090224.034430.250330119.davem@davemloft.net>
References: <1235463419-25146-1-git-send-email-dhananjay@netxen.com>
	<1235463419-25146-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41156
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753259AbZBXLot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 06:44:49 -0500
In-Reply-To: <1235463419-25146-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Tue, 24 Feb 2009 00:16:58 -0800

> The PCI function to physical port mapping is valid only for
> old firmware. New firmware (4.0.0+) abstracts this.
> So driver should never try to access phy using invalid
> mapping. The behavior is unpredictable when PCI functions
> 4-7 are enabled on the same NIC.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
