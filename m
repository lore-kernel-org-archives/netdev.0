From: David Miller <davem@davemloft.net>
Subject: Re: e1000 softirq load balancing
Date: Tue, 14 Oct 2008 12:51:56 -0700 (PDT)
Message-ID: <20081014.125156.92616351.davem@davemloft.net>
References: <48F4ED7E.4070308@cs.utexas.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: porterde@cs.utexas.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52066
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751532AbYJNTwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 15:52:20 -0400
In-Reply-To: <48F4ED7E.4070308@cs.utexas.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Porter <porterde@cs.utexas.edu>
Date: Tue, 14 Oct 2008 14:05:34 -0500

> It seems to me that with 4 independent NICs and plenty of CPUs to
> spare, I ought to be able to assign one softirq daemon to each NIC
> rather than funnelling all of the traffic through 1 or 2.

Traffic doesn't get distributed unless the NIC has support
for RX flow seperation and PCI MSI-X interrupts.  Your NICs
do not.

So no matter how hard you try, each NIC is going to have it's
packets processed essentially on one cpu.
