From: David Miller <davem@davemloft.net>
Subject: Re: LRO restructuring?
Date: Mon, 11 Aug 2008 18:39:13 -0700 (PDT)
Message-ID: <20080811.183913.09225669.davem@davemloft.net>
References: <20080811.175434.215224347.davem@davemloft.net>
	<20080812010004.GD18547@gondor.apana.org.au>
	<48A0E7A3.6030200@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, gallatin@myri.com,
	netdev@vger.kernel.org, brice@myri.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58281
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750852AbYHLBjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 21:39:12 -0400
In-Reply-To: <48A0E7A3.6030200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 11 Aug 2008 18:30:11 -0700

> Even if it was verified I think you want to keep the checksums from the 
> header.   Since an intermediate device isn't supposed to be peeking at 
> the TCP part anyway, it wouldn't do to drop the segment ourselves, pass 
> it along to be dropped by the ultimate reciever.  And if there is 
> something amis in the verification or the regeneration, we don't want to 
>   introduce silent data corruption.
> 
> Likely that also goes for the IP header checksum...

IP header is a little different, intermediate nodes should verify it
(and we do adjust it when  decrementing TTL).
