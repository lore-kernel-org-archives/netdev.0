From: David Miller <davem@davemloft.net>
Subject: Re: [MACVLAN 01/02]: Remove unnecessary IFF_UP check
Date: Mon, 19 Nov 2007 22:00:13 -0800 (PST)
Message-ID: <20071119.220013.184543453.davem@davemloft.net>
References: <20071115155427.12874.34461.sendpatchset@localhost.localdomain>
	<20071115155429.12874.28112.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44902
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753492AbXKTGAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:00:14 -0500
In-Reply-To: <20071115155429.12874.28112.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 15 Nov 2007 16:54:30 +0100 (MET)

> [MACVLAN]: Remove unnecessary IFF_UP check
> 
> Only devices that are UP are in the hash, so macvlan_broadcast() doesn't
> need to check for IFF_UP.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.25, thanks!
