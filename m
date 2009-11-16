From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: fix 802.3ad standards compliance
 error
Date: Sun, 15 Nov 2009 22:22:48 -0800 (PST)
Message-ID: <20091115.222248.00597013.davem@davemloft.net>
References: <3048.1258153981@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, martin@gear6.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751276AbZKPGWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 01:22:32 -0500
In-Reply-To: <3048.1258153981@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 13 Nov 2009 15:13:01 -0800

> 	The language of 802.3ad 43.4.9 requires the "recordPDU" function
> to, in part, compare the Partner parameter values in a received LACPDU
> to the stored Actor values.  If those match, then the Partner's
> synchronization state is set to true.
> 
> 	The current 802.3ad implementation is performing these steps out
> of order; first, the synchronization check is done, then the paramters are
> checked to see if they match (the synch check being done against a match
> check of a prior LACPDU).  This causes delays in establishing aggregators
> in some circumstances.
 ...
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks.

A patch that cleans up all of the non-standard stuff in these
sources, as pointed out by Stephen, would be most welcome.
