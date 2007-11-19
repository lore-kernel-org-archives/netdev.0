From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Mon, 19 Nov 2007 00:26:04 -0800 (PST)
Message-ID: <20071119.002604.208363785.davem@davemloft.net>
References: <20071118214515.GA8161@one.firstfloor.org>
	<20071118.144010.236028466.davem@davemloft.net>
	<20071119010929.GA32651@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751841AbXKSI0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 03:26:04 -0500
In-Reply-To: <20071119010929.GA32651@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 19 Nov 2007 09:09:29 +0800

> In any case, I just looked up RFC1213 and it says:
> 
>           udpInDatagrams OBJECT-TYPE
>               SYNTAX  Counter
>               ACCESS  read-only
>               STATUS  mandatory
>               DESCRIPTION
>                       "The total number of UDP datagrams delivered to
>                       UDP users."
>               ::= { udp 1 }
> 
> So I think incrementing it in recvmsg is acceptable.

Point taken, thanks for checking that.
