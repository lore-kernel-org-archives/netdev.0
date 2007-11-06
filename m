From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv6] SNMP: Restore Udp6InErrors incrementation
Date: Mon, 05 Nov 2007 21:29:33 -0800 (PST)
Message-ID: <20071105.212933.252093811.davem@davemloft.net>
References: <20071101224638.b954a697.mitch@linux.vnet.ibm.com>
	<20071101150500.GB7965@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch@linux.vnet.ibm.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751832AbXKFF3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 00:29:34 -0500
In-Reply-To: <20071101150500.GB7965@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 1 Nov 2007 23:05:00 +0800

> On Thu, Nov 01, 2007 at 10:46:38PM +0900, Mitsuru Chinen wrote:
> > As the checksum verification is postponed till user calls recv or poll,
> > the inrementation of Udp6InErrors counter should be also postponed.
> > Currently, it is postponed in non-blocking operation case. However it
> > should be postponed in all case like the IPv4 code.
> > 
> > Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> 
> Looks good to me.  Thanks for catching this!

Applied.
