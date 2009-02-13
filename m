From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix link test for e1000 and e1000e when iface is down
Date: Thu, 12 Feb 2009 16:29:27 -0800 (PST)
Message-ID: <20090212.162927.81181325.davem@davemloft.net>
References: <200902101435.58331.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: adetsch@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39666
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752010AbZBMA3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:29:33 -0500
In-Reply-To: <200902101435.58331.adetsch@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andre Detsch <adetsch@br.ibm.com>
Date: Tue, 10 Feb 2009 14:35:58 -0200

> 
> When running ethtool -t on an interface that was just
> brought down, the link test was failing. That's because
> we need to perform a reset on the interface to be able
> to check the link status correctly. There is no problem
> on doing such reset right before the test, as the link
> test routine is prepared to wait for autoneg to complete
> if that is the case.
> 
> Signed-off-by: Andre Detsch <adetsch@br.ibm.com>

Can I get some Intel ACKs on this?
