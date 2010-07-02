From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ehea: Allocate stats buffer with GFP_KERNEL
Date: Thu, 01 Jul 2010 22:48:05 -0700 (PDT)
Message-ID: <20100701.224805.221588889.davem@davemloft.net>
References: <201006302159.o5ULx8ow025348@d01av03.pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, osstklei@de.ibm.com, raisch@de.ibm.com,
	netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49295
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644Ab0GBFry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:47:54 -0400
In-Reply-To: <201006302159.o5ULx8ow025348@d01av03.pok.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian King <brking@linux.vnet.ibm.com>
Date: Wed, 30 Jun 2010 16:59:12 -0500

> 
> Since ehea_get_stats calls ehea_h_query_ehea_port, which
> can sleep, we can also sleep when allocating a page in
> this function. This fixes some memory allocation failure
> warnings seen under low memory conditions.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>

Applied to net-next-2.6
