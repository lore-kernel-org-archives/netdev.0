From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ksz884x: don't copy too much in
 netdev_set_mac_address()
Date: Thu, 19 Apr 2012 13:25:58 -0400 (EDT)
Message-ID: <20120419.132558.135758710709714950.davem@davemloft.net>
References: <1334758394.3209.156.camel@deadeye>
	<20120419070018.GA16645@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tristram.Ha@micrel.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab2DSR0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 13:26:13 -0400
In-Reply-To: <20120419070018.GA16645@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 19 Apr 2012 10:00:19 +0300

> MAX_ADDR_LEN is 32.  ETH_ALEN is 6.  mac->sa_data is a 14 byte array, so
> the memcpy() is doing a read past the end of the array.  I asked about
> this on netdev and Ben Hutchings told me it's supposed to be copying
> ETH_ALEN bytes (thanks Ben).
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
