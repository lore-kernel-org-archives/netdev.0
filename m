From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/7] bonding: fix compile error if debug enabled
Date: Tue, 09 Dec 2008 23:09:02 -0800 (PST)
Message-ID: <20081209.230902.220303718.davem@davemloft.net>
References: <20081209200750.490739902@eitzenberger.org>
	<20081209201447.431916236@eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39297
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753652AbYLJHJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 02:09:01 -0500
In-Reply-To: <20081209201447.431916236@eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: holger@eitzenberger.org
Date: Tue, 09 Dec 2008 21:07:53 +0100

> This is what I get if debug is enabled:
> 
> drivers/net/bonding/bond_ipv6.c: In function 'bond_na_send':
> drivers/net/bonding/bond_ipv6.c:75: error: 'slave' undeclared (first use in this function)
> drivers/net/bonding/bond_ipv6.c:75: error: (Each undeclared identifier is reported only once
> drivers/net/bonding/bond_ipv6.c:75: error: for each function it appears in.)
> 
> This patch fixes that.
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Applied.
