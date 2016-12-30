From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv4: dst for local input routes should use
 l3mdev if relevant
Date: Thu, 29 Dec 2016 22:28:08 -0500 (EST)
Message-ID: <20161229.222808.764899390610544123.davem@davemloft.net>
References: <1483054143-11050-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752946AbcL3D2J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 22:28:09 -0500
In-Reply-To: <1483054143-11050-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 29 Dec 2016 15:29:03 -0800

> IPv4 output routes already use l3mdev device instead of loopback for dst's
> if it is applicable. Change local input routes to do the same.
> 
> This fixes icmp responses for unreachable UDP ports which are directed
> to the wrong table after commit 9d1a6c4ea43e4 because local_input
> routes use the loopback device. Moving from ingress device to loopback
> loses the L3 domain causing responses based on the dst to get to lost.
> 
> Fixes: 9d1a6c4ea43e4 ("net: icmp_route_lookup should use rt dev to
> 		       determine L3 domain")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks David.
