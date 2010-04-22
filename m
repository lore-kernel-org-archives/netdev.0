From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NIU support for skb->rxhash
Date: Thu, 22 Apr 2010 15:24:05 -0700 (PDT)
Message-ID: <20100422.152405.254217234.davem@davemloft.net>
References: <20100422092120.603e83b8@nehalam>
	<20100422.143606.56183045.davem@davemloft.net>
	<20100422151140.01f19059@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57954
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab0DVWYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 18:24:01 -0400
In-Reply-To: <20100422151140.01f19059@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 22 Apr 2010 15:11:40 -0700

> On Thu, 22 Apr 2010 14:36:06 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Thu, 22 Apr 2010 09:21:20 -0700
>> 
>> > P.s: where is that patch seems lost in patchwork
>> 
>> I marked it as RFC since that's what it was.
> 
> 
> It works fine, put it net-next

There is nothing CONFIG_RPS dependent about ->rxhash, we could
use it for many other things.

Please take away that CONFIG_RPS ifdef and I'll apply it.
