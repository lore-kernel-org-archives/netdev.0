From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: interpret IP headers for ECN correctly
Date: Mon, 07 Dec 2015 17:06:59 -0500 (EST)
Message-ID: <20151207.170659.1239107087073943876.davem@davemloft.net>
References: <47068a34770a946e847903daa73d130d4fcbbc0e.1449502140.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803AbbLGWHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 17:07:00 -0500
In-Reply-To: <47068a34770a946e847903daa73d130d4fcbbc0e.1449502140.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Mon,  7 Dec 2015 16:29:08 +0100

> When looking for outer IP header, use the actual socket address family, not
> the address family of the default destination which is not set for metadata
> based interfaces (and doesn't have to match the address family of the
> received packet even if it was set).
> 
> Fix also the misleading comment.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks.
