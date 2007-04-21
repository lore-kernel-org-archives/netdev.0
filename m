From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Get rid of netdev_nit
Date: Fri, 20 Apr 2007 17:02:10 -0700 (PDT)
Message-ID: <20070420.170210.129476956.davem@davemloft.net>
References: <20070312210907.509184287@linux-foundation.org>
	<45F63891.6040307@cosmosbay.com>
	<20070313142635.68966970@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51440
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752051AbXDUACH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 20:02:07 -0400
In-Reply-To: <20070313142635.68966970@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 13 Mar 2007 14:26:35 -0700

> It isn't any faster to test a boolean global variable than do a 
> simple check for empty list.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

I'll apply this, thanks Stephen.

I think the history is that long ago we used to export
netdev_nit and we didn't want to export the details of
the list implementation too.
