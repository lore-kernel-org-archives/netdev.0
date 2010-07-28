From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] macvlan: Fix rx counters update in
 macvlan_handle_frame()
Date: Tue, 27 Jul 2010 21:03:09 -0700 (PDT)
Message-ID: <20100727.210309.212422099.davem@davemloft.net>
References: <1280257807.27059.4.camel@w-sridhar.beaverton.ibm.com>
	<20100728001404.GA14038@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750800Ab0G1ECv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 00:02:51 -0400
In-Reply-To: <20100728001404.GA14038@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 28 Jul 2010 08:14:04 +0800

> On Tue, Jul 27, 2010 at 12:10:07PM -0700, Sridhar Samudrala wrote:
>> Fix macvlan_handle_frame() to update the rx counters based
>> on the return value of the vlan->receive call.
>> 
>> Updated the patch to not do any packet count drops when the interface
>> is down based on Herber'ts comments.
>> 
>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next-2.6, thanks.
