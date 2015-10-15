From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 14 Oct 2015 18:06:59 -0700 (PDT)
Message-ID: <20151014.180659.1860914575436401565.davem@davemloft.net>
References: <20151013.184539.1401344867685512636.davem@davemloft.net>
	<1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
	<561E7E57.2070001@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	hannes@redhat.com, nicolas.dichtel@6wind.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbbJOAu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 20:50:57 -0400
In-Reply-To: <561E7E57.2070001@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 14 Oct 2015 10:09:59 -0600

> This latest patch makes IPv6 static addresses on par with IPv4,
> including error paths.

I don't agree with ipv4's behavior... and just because ipv4 does
something poorly doesn't mean we get a free pass to replicate that
lazyness in ipv6.
