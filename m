From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v5] ipv6:introduce function to find route for redirect
Date: Wed, 4 Sep 2013 20:36:02 +0200
Message-ID: <20130904183602.GA13136@order.stressinduktion.org>
References: <52271D15.1000806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37649 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755519Ab3IDSgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:36:04 -0400
Content-Disposition: inline
In-Reply-To: <52271D15.1000806@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 04, 2013 at 07:44:21PM +0800, Duan Jiong wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> RFC 4861 says that the IP source address of the Redirect is the
> same as the current first-hop router for the specified ICMP
> Destination Address, so the gateway should be taken into
> consideration when we find the route for redirect.
> 
> There was once a check in commit
> a6279458c534d01ccc39498aba61c93083ee0372 ("NDISC: Search over
> all possible rules on receipt of redirect.") and the check
> went away in commit b94f1c0904da9b8bf031667afc48080ba7c3e8c9
> ("ipv6: Use icmpv6_notify() to propagate redirect, instead of
> rt6_redirect()").
> 
> The bug is only "exploitable" on layer-2 because the source
> address of the redirect is checked to be a valid link-local
> address but it makes spoofing a lot easier in the same L2
> domain nonetheless.
> 
> Thanks very much for Hannes's help.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Tested and looks good!

Thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
