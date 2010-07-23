From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next v2] mv643xx_eth: potential null dereference
Date: Fri, 23 Jul 2010 13:05:55 -0700 (PDT)
Message-ID: <20100723.130555.35023547.davem@davemloft.net>
References: <1279881177.24768.1623.camel@Joe-Laptop.home>
	<20100723110504.GG26313@bicker>
	<20100723111818.GV21121@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, joe@perches.com, jpirko@redhat.com,
	kirjanov@gmail.com, saeed@marvell.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753038Ab0GWUFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 16:05:39 -0400
In-Reply-To: <20100723111818.GV21121@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Fri, 23 Jul 2010 13:18:18 +0200

> On Fri, Jul 23, 2010 at 01:05:05PM +0200, Dan Carpenter wrote:
> 
>> We assume that "pd" can be null on the previous line, and throughout the
>> function so we should check it here as well.  This was introduced by
>> 9b2c2ff7a1c0 "mv643xx_eth: use sw csum for big packets"
>> 
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

Applied.
