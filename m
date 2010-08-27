From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix wrong return from bnx2x_trylock_hw_lock
Date: Thu, 26 Aug 2010 22:04:00 -0700 (PDT)
Message-ID: <20100826.220400.115912823.davem@davemloft.net>
References: <1282880943.2501.13.camel@edumazet-laptop>
	<1282884884.14181.1.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, vladz@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52995
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753393Ab0H0FDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 01:03:44 -0400
In-Reply-To: <1282884884.14181.1.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Fri, 27 Aug 2010 07:54:44 +0300

> On Thu, 2010-08-26 at 20:49 -0700, Eric Dumazet wrote:
>> bnx2x_trylock_hw_lock() returns a bool :
>> 
>> true if succeeded to acquire the lock.
>> false in case of error.
>> 
>> -EINVAL is not an acceptable value, since its promoted to true.
> 
> Indeed - thanks Eric!
> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
