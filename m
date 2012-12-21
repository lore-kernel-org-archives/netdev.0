From: David Miller <davem@davemloft.net>
Subject: Re: [patch] solos-pci: double lock in geos_gpio_store()
Date: Fri, 21 Dec 2012 13:16:46 -0800 (PST)
Message-ID: <20121221.131646.463198363776718641.davem@davemloft.net>
References: <20121220074845.GA14716@elgon.mountain>
	<1355995348.18919.104.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, chas@cmf.nrl.navy.mil,
	nathan@traverse.com.au, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, kbuild@01.org
To: david.woodhouse@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab2LUVQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 16:16:47 -0500
In-Reply-To: <1355995348.18919.104.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Woodhouse, David" <david.woodhouse@intel.com>
Date: Thu, 20 Dec 2012 09:22:26 +0000

> On Thu, 2012-12-20 at 10:48 +0300, Dan Carpenter wrote:
>> There is a typo here so we do a double lock instead of an unlock.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> ---
>> Only needed in linux-next.  Introduced in f9baad02e7411d9 [14/17]
>> solos-pci: add GPIO support for newer versions on Geos board
> 
> Ah, crap. That was my fault; it was part of my "improvement" to Nathan's
> patch. Sorry.
> 
> Acked-by: David Woodhouse <David.Woodhouse@intel.com>

Applied.
