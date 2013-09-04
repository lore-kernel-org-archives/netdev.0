From: David Miller <davem@davemloft.net>
Subject: Re: [patch] caif: add a sanity check to the tty name
Date: Wed, 04 Sep 2013 00:54:13 -0400 (EDT)
Message-ID: <20130904.005413.1385684551140148010.davem@davemloft.net>
References: <20130903090232.GA4351@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761368Ab3IDEyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 00:54:14 -0400
In-Reply-To: <20130903090232.GA4351@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 3 Sep 2013 12:02:32 +0300

> "tty->name" and "name" are a 64 character buffers.  My static checker
> complains because we add the "cf" on the front so it look like we are
> copying a 66 character string into a 64 character buffer.
> 
> Also if the name is larger than IFNAMSIZ (16) it triggers a BUG_ON()
> inside the call to alloc_netdev().
> 
> This is all under CAP_SYS_ADMIN so it's not a security fix, it just adds
> a little robustness.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
