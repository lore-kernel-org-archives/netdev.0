From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] dns_resolver: Null-terminate the right string
Date: Sun, 20 Jul 2014 22:34:12 -0700 (PDT)
Message-ID: <20140720.223412.588018040301449538.davem@davemloft.net>
References: <1405897608.8631.13.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, manuel.schoelling@gmx.de
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbaGUFeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 01:34:13 -0400
In-Reply-To: <1405897608.8631.13.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 21 Jul 2014 00:06:48 +0100

> *_result[len] is parsed as *(_result[len]) which is not at all what we
> want to touch here.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Fixes: 84a7c0b1db1c ("dns_resolver: assure that dns_query() result is null-terminated")
> ---
> v2: Add the Fixes header

Applied, thanks Ben.
