From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] atl2: Disable unimplemented scatter/gather feature
Date: Thu, 21 Apr 2016 15:12:48 -0400 (EDT)
Message-ID: <20160421.151248.1066170820995763060.davem@davemloft.net>
References: <20160420222308.GJ3348@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jyackoski@crypto-nite.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbcDUTMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:12:49 -0400
In-Reply-To: <20160420222308.GJ3348@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 20 Apr 2016 23:23:08 +0100

> atl2 includes NETIF_F_SG in hw_features even though it has no support
> for non-linear skbs.  This bug was originally harmless since the
> driver does not claim to implement checksum offload and that used to
> be a requirement for SG.
> 
> Now that SG and checksum offload are independent features, if you
> explicitly enable SG *and* use one of the rare protocols that can use
> SG without checkusm offload, this potentially leaks sensitive
> information (before you notice that it just isn't working).  Therefore
> this obscure bug has been designated CVE-2016-2117.
> 
> Reported-by: Justin Yackoski <jyackoski@crypto-nite.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Fixes: ec5f06156423 ("net: Kill link between CSUM and SG features.")

Applied and queued up for -stable, thanks.
