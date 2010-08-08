From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfq: add dummy bind/unbind handles
Date: Sat, 07 Aug 2010 22:45:14 -0700 (PDT)
Message-ID: <20100807.224514.137860816.davem@davemloft.net>
References: <20100806145818.66d389eb@nehalam>
	<20100806152313.43abc30b@nehalam>
	<4C5C97F3.3010604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, franchoze@yandex.ru
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56450
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751328Ab0HHFoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 01:44:55 -0400
In-Reply-To: <4C5C97F3.3010604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 07 Aug 2010 01:17:07 +0200

> Stephen Hemminger wrote, On 07.08.2010 00:23:
> 
>> Applying a filter to an SFQ qdisc would cause null dereference
>> in tcf_bind_filter because although SFQ is classful it didn't
>> have all the necessary equipment.
>> 
>> Better alternative to changing tcf_bind API is to just fix
>> SFQ.  This should go to net-2.6 and stable.
>> 
> 
> Hmm... FYI, actually I've sent already a similar patch to the
> original bug report thread (except .unbind_tcf method which
> doesn't matter for fixing this bug, so should be rather
> implemented in a separate patch, if needed at all in this
> case).

Agreed, I can't see a way that unbind can ever be invoked
if the bind call always returns zero.

Therefore I'll apply Jarek's patch, thanks everyone.
