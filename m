From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: dereference of he_dev->rbps_virt in
 he_init_group()
Date: Fri, 11 Sep 2009 12:37:25 -0700 (PDT)
Message-ID: <20090911.123725.223971259.davem@davemloft.net>
References: <4A997A78.9080309@gmail.com>
	<20090902.232548.238393942.davem@davemloft.net>
	<4AA25B06.2090703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57539
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756182AbZIKThI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:37:08 -0400
In-Reply-To: <4AA25B06.2090703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 05 Sep 2009 14:35:18 +0200

> he_dev->rbps_virt or he_dev->rbpl_virt allocation may fail, so check
> them. Make sure that he_init_group() cleans up after errors.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>> These new return statements will both leak resources allocated
>> earlier.
>> 
>> All the caller is going to do is return -ENOMEM as well and
>> it does not cleanup actions at all.
>> 
>> Please fix this up.
> 
> I am new to this api, so please review.

Looks ok, applied, thanks.
