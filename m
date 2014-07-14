From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dns_resolver: Null-terminate the right string
Date: Sun, 13 Jul 2014 22:53:51 -0700 (PDT)
Message-ID: <20140713.225351.231848412675803840.davem@davemloft.net>
References: <1405110685.26540.95.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, manuel.schoelling@gmx.de
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbaGNFxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 01:53:52 -0400
In-Reply-To: <1405110685.26540.95.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 11 Jul 2014 21:31:25 +0100

> *_result[len] is parsed as *(_result[len]) which is not at all what we
> want to touch here.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Please add an appropriate Fixes: tag (for 84a7c0b1) or commit
reference in the commit message proper.

Thanks.
