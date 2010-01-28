From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: bond_open error return value
Date: Thu, 28 Jan 2010 05:58:41 -0800 (PST)
Message-ID: <20100128.055841.39692850.davem@davemloft.net>
References: <20100126013415.0120d6a9@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51462
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756203Ab0A1N63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 08:58:29 -0500
In-Reply-To: <20100126013415.0120d6a9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 26 Jan 2010 01:34:15 -0800

> The convention for API functions in kernel is to return errno value;
> bond_open would return -1 if alb setup failed. The only reason that
> could happen is if kmalloc() failed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
