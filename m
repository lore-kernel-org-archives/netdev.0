From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] sfc: Optimise falcon_writel_page_locked() for page
 > 0
Date: Sat, 21 Mar 2009 19:10:00 -0700 (PDT)
Message-ID: <20090321.191000.57944958.davem@davemloft.net>
References: <1237591540.3217.6.camel@achroite>
	<1237591633.3217.12.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753122AbZCVCKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:10:14 -0400
In-Reply-To: <1237591633.3217.12.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 20 Mar 2009 23:27:13 +0000

> The bug this function works around only applies to the first set of
> page-mapped registers; other pages can be written without locking.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
