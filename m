From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24]S2io: Enhance device error/alarm handling
Date: Tue, 14 Aug 2007 01:04:25 -0400
Message-ID: <46C137D9.7050504@garzik.org>
References: <1186542917.1997.17.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53087 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759574AbXHNFE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:04:27 -0400
In-Reply-To: <1186542917.1997.17.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa wrote:
> - Added support to poll for entire set of device errors and alarms.
> - Optimized interrupt routine fast path.
> - Removed the unused variable, intr_type, in device private structure.
> 
> Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

please split this patch up into multiple patches.

In general it's OK to combine several small, minor changes together, but 
this patch was pretty big.  at that point, you need to start looking 
into splitting up patches into separate logical changes (intr_type clean 
in its own patch, irq handler optimization in its own patch, etc.).

More patches means that each patch is smaller, making it easier to 
review.  It also means that automated tools such as git-bisect can 
easily identify which change created a regression, should one appear.




