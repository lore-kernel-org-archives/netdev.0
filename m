From: David Miller <davem@davemloft.net>
Subject: Re: [patch] missing dev_put() on error path in vif_add()
Date: Fri, 13 Nov 2009 19:57:54 -0800 (PST)
Message-ID: <20091113.195754.182893932.davem@davemloft.net>
References: <alpine.DEB.2.00.0911111339100.9485@bicker>
	<4AFB77DA.3040600@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, netdev@vger.kernel.org
To: ellre923@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35602
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757595AbZKND5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:57:38 -0500
In-Reply-To: <4AFB77DA.3040600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <ellre923@gmail.com>
Date: Thu, 12 Nov 2009 10:50:02 +0800

> Dan Carpenter said the following on 2009-11-11 20:03:
>> The other error paths in front of this one have a dev_put() but this one 
>> got missed.
>> 
>> Found by smatch static checker.
 ...
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
 ...
> It's my fault. Introduced in 7dc00c82cbb0119cf4663f65bbaa2cc55f961db2.
> 
> Acked-by: Wang Chen <ellre923@gmail.com>

Applied, thanks.
